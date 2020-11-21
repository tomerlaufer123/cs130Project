'''
File: bing.py
Description: Class for web scrapping.
             Base code is cloned from https://github.com/gurugaurav/bing_image_downloader.
             Changed are made to:
                1. Avoid downloading duplicate images
                2. Resize images so that the shortest side = 100 pixel.
                3. Remove unnecessary print statements
'''
from pathlib import Path
import os
import sys
import urllib.request
import urllib
import imghdr
import posixpath
import re
import shutil
from PIL import Image
import requests


class Bing:
    def __init__(self, query, limit, output_dir, adult, timeout, verbose, filters=''):
        self.download_count = 0
        self.query = query
        self.output_dir = output_dir
        self.adult = adult
        self.filters = filters
        self.downloaded_links = []
        self.limit = limit
        self.timeout = timeout
        self.verbose = verbose

        self.headers = {'User-Agent': 'Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:60.0) Gecko/20100101 Firefox/60.0'}
        self.page_counter = 0

    def save_image(self, link, file_path):
        img = Image.open(requests.get(link, stream=True).raw)

        # Resize image to save space
        img_width, img_height = img.size
        if img_width < img_height:
            img = img.resize((100, img_height*100//img_width))
        else:
            img = img.resize((img_width*100//img_height, 100))

        # Save image
        img.save(file_path)

    def download_image(self, link):
        self.download_count += 1

        # Get the image link
        try:
            file_path = os.path.join(
                ".", self.output_dir, f"bing_{self.query}_{self.download_count}.jpg")
            self.save_image(link, file_path) 
        except Exception as e:
            self.download_count -= 1

    def run(self):
        prev = 0
        while self.download_count < self.limit:
            try:
                request_url = 'https://www.bing.com/images/async?q=' + urllib.parse.quote_plus(self.query) \
                            + '&first=' + str(self.page_counter) + '&count=' + str(self.limit) \
                            + '&adlt=' + self.adult + '&qft=' + self.filters
                request = urllib.request.Request(request_url, None, headers=self.headers)
                response = urllib.request.urlopen(request)
                html = response.read().decode('utf8')
                links = re.findall('murl&quot;:&quot;(.*?)&quot;', html)

                for link in links:
                    # Avoid downloading duplicate images
                    if link in self.downloaded_links:
                        continue
                    elif self.download_count < self.limit:
                        self.download_image(link)
                        self.downloaded_links.append(link)
                        if self.verbose \
                                and self.download_count % (self.limit//10) == 0 \
                                and prev != self.download_count:
                            print(f"Downloaded {self.download_count}/{self.limit} images")
                            prev = self.download_count
                    else:
                        break
            except:
                pass

            self.page_counter += 1
