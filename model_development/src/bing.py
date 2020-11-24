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
import io
import os
import sys
# import urllib
import posixpath
import re
import shutil
from PIL import Image
import requests
import imghdr


class Bing:
    def __init__(self, query, limit, output_dir, adult, timeout, verbose, offset):
        self.d_count = 0
        self.query = query
        self.output_dir = output_dir
        self.adult = adult
        self.d_links = []
        self.limit = limit
        self.timeout = timeout
        self.verbose = verbose
        self.offset = offset

        self.headers = {'User-Agent': 'Mozilla/5.0 (X11; Fedora; Linux x86_64; rv:60.0) Gecko/20100101 Chrome/46.0.2490.80 Safari/537.36'}
        self.p_count = 0

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
        self.d_count += 1
        # Get the image link
        try:
            file_path = os.path.join(
                ".",
                self.output_dir,
                f"bing_{' '.join(self.query)}_{self.d_count}.jpg")
            
            self.save_image(link, file_path)
        except Exception:
            self.d_count -= 1

    def run(self):
        prev = 0
        while self.d_count < self.limit:
            params = {
                "q": '+'.join(self.query),
                "first": self.p_count*self.offset,
                "count": self.offset,
                "adlt": "off"}
                # "mkt": "en-us"}

            response = requests.get(
                "https://www.bing.com/images/async",
                headers=self.headers,
                params=params)

            links_ = re.findall('murl&quot;:&quot;(.*?)&quot;', response.text)

            # Avoid downloading duplicate images
            links = [link for link in links_ if link not in self.d_links]
            self.d_links += links

            for link in links:
                # print(link)
                if self.d_count < self.limit:
                    self.download_image(link)
                    if self.verbose \
                            and self.d_count % (self.limit//10) == 0 \
                            and prev != self.d_count:
                        print(f"Downloaded {self.d_count}/{self.limit} images")
                        prev = self.d_count
                else:
                    break

            self.p_count += 1
