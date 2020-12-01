'''
File: google_crawler.py
Description: A class to download images from google image search.
             Used in `download_images.py`.
             You have to install chromedriver from https://chromedriver.chromium.org/downloads
             and set `driver_bin` (i.e. path to chromedriver) appropriately.
'''

import io
import requests
import re
import time
import base64
import os
import traceback
import sys
from random import uniform
from tqdm import tqdm
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.proxy import Proxy
from selenium.webdriver.support.ui import Select
from PIL import Image
from bs4 import BeautifulSoup
from fake_useragent import UserAgent


class Google:
    def __init__(self, query, limit, output_dir, skip=0, timeout=20,
                 p_flag=False, driver_bin="./misc/chromedriver"):
        self.d_count = 0
        self.num_data_image = 0
        self.query = query
        self.output_dir = output_dir
        self.limit = limit
        self.skip = int(skip)
        self.timeout = timeout
        self.ua = UserAgent(verify_ssl=False, use_cache_server=False)
        self.driver_bin = driver_bin
        self.reached_end = False
        self.p_flag = p_flag
        if self.p_flag:
            self.proxies = self.get_proxies()
            self.proxy = self.proxies[0]
            self.max_retry = 100
        else:
            self.max_retry = 3

    def eprint(self, *args):
        print(*args, file=sys.stderr)

    def get_proxies(self):
        # Open the website
        options = Options()
        options.add_argument("headless")
        options.add_argument(f"--user-agent={self.ua.random}")
        driver = webdriver.Chrome(
            options=options,
            executable_path=self.driver_bin)
        driver.get("https://free-proxy-list.net/")

        # Change table to show http proxies first
        hx = Select(driver.find_elements_by_tag_name("select")[5])
        hx.select_by_value("yes")

        # Get html and close browser
        html = driver.page_source
        driver.quit()

        # Parse html to get proxies
        prxy_tbl = BeautifulSoup(html, "html.parser")
        tbl = prxy_tbl.find_all("tbody")[0].find_all("tr")
        proxies = []
        for tr in tbl:
            temp = re.split("<.*?><.*?>", str(tr))
            if temp[7] == "yes":
                proxies.append(f"{temp[1]}:{temp[2]}")
        return proxies

    def set_proxy(self):
        idx = int(time.time()) % len(self.proxies)
        self.proxy = self.proxies[idx]

    def get_url_image(self, link):
        # Get image from url
        for _ in range(self.max_retry):
            try:
                if self.p_flag:
                    raw_img = requests.get(
                        link,
                        stream=True,
                        proxies={"http": self.proxy, "https": self.proxy},
                        headers={"User-Agent": self.ua.random},
                        timeout=self.timeout).raw
                else:
                    time.sleep(uniform(1, 3))
                    raw_img = requests.get(
                        link,
                        stream=True,
                        headers={"User-Agent": self.ua.random},
                        timeout=self.timeout).raw
                return raw_img
            except Exception as err:
                self.eprint(f"[!] Error: {err}")
                self.eprint(traceback.format_exc())
                if self.p_flag:
                    self.proxies.remove(self.proxy)
                    self.set_proxy()
                    # Get new proxies
                    if len(self.proxies) < 2:
                        self.proxies = self.get_proxies()
        return None

    def get_base64_image(self, data):
        return io.BytesIO(base64.b64decode(data.split(',', 1)[1]))

    def download_image(self, src):
        file_path = os.path.join(
            self.output_dir,
            f"google_{' '.join(self.query)}_{self.d_count}.jpg")

        # Check type of image src
        if src[:4] == "http":
            if self.d_count > self.limit:
                return
            raw_img = self.get_url_image(src)
        elif src[:10] == "data:image":
            raw_img = self.get_base64_image(src)
        else:
            raw_img = None

        # Save image
        if raw_img is not None:
            # Save image
            img = Image.open(raw_img)
            if img.mode != "RGB":
                img = img.convert("RGB")
            img.save(file_path)
            img.close()
            self.d_count += 1

    def get_src_list(self):
        options = Options()
        options.add_argument('headless')

        for _ in range(self.max_retry):
            options.add_argument(f"--user-agent={self.ua.random}")
            try:
                if self.p_flag:
                    # Set proxy
                    webdriver.DesiredCapabilities.CHROME['proxy'] = {
                        "httpProxy": self.proxy,
                        "ftpProxy": self.proxy,
                        "sslProxy": self.proxy,
                        "proxyType": "MANUAL"}
                    capabilities = webdriver.DesiredCapabilities.CHROME

                    # Open browser
                    driver = webdriver.Chrome(
                        options=options,
                        executable_path=self.driver_bin,
                        desired_capabilities=capabilities)
                else:
                    driver = webdriver.Chrome(
                        options=options,
                        executable_path=self.driver_bin)

                q = '+'.join(self.query)
                driver.get(f"https://www.google.com/search?&tbm=isch&cr=countryUS&safe=active&q={q}")
                curr_h = driver.execute_script("return document.body.scrollHeight")

                # Get at least self.limit many images
                while True:
                    # Check how many images 
                    items = driver.find_elements_by_class_name("rg_i.Q4LuWd")
                    num_items = len(items)
                    driver.implicitly_wait(uniform(1, 2))
                    if num_items >= self.limit:
                        break

                    # Scroll down
                    driver.execute_script(f"window.scrollTo(0, {curr_h});")

                    # Reached the buttom of current page
                    new_h = driver.execute_script("return document.body.scrollHeight")
                    if curr_h == new_h:
                        try:
                            clickable = driver \
                                .find_elements_by_class_name("YstHxe")[0] \
                                .get_attribute("style") == ''
                            data_status = driver \
                                .find_elements_by_class_name("DwpMZe")[0] \
                                .get_attribute("data-status")
                        except Exception:
                            break

                        if data_status == '2' or data_status == '3':
                            # Reached the end of the results
                            self.eprint(f"[-] Reached the end")
                            self.reached_end = True
                            break
                        elif clickable:
                            # Load more images
                            driver.find_elements_by_class_name("mye4qd")[0].click()
                    curr_h = new_h

                src_list = []
                for item in items:
                    if item.get_attribute("src") is not None:
                        src_list.append(item.get_attribute("src"))
                        if item.get_attribute("src")[:10] == "data:image":
                            self.num_data_image += 1
                    elif item.get_attribute("data-src") is not None:
                        src_list.append(item.get_attribute("data-src"))
                driver.quit()
                return src_list

            except Exception as err:
                self.eprint(f"[!] Error: {err}")
                self.eprint(traceback.format_exc())
                driver.quit()
                if self.p_flag:
                    proxies.remove(self.proxy)
                    self.set_proxy()
                    if len(self.proxies) == 1:
                        self.proxies = self.get_proxies()
        return []

    def run(self):
        q_tag = ['#'+q for q in self.query]
        self.eprint(f"[ ] Collecting {self.limit} image sources for: {' '.join(q_tag)}")
        s = time.time()
        src_list = self.get_src_list()
        num_src = len(src_list)
        e = time.time()

        if num_src == 0:
            self.eprint(f"[!] Something went wrong - No image downloaded [{e-s:.2f} sec]")
            print(f"[!] Retry search on: {'+'.join(self.query)} {self.limit}")

        else:
            q_tag = ['#'+q for q in self.query]
            self.eprint(f"[ ] Collected {num_src} image sources [{e-s:.2f} sec]")
            upper = max(self.limit, self.num_data_image)
            for src in tqdm(src_list[self.skip:upper], unit="image"):
                self.download_image(src)

        c = '+' if self.d_count > 0 else '-'
        self.eprint(f"[{c}] Downloaded {self.d_count} images for: {' '.join(q_tag)}")
        return int(self.d_count), self.reached_end
