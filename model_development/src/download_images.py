'''
File: download_images.py
Description: This is used to download additional images.
             `download` is copied from https://github.com/gurugaurav/bing_image_downloader.
             See `notebooks/6-additional-images.ipynb` for related info.
Usage: python download_images.py add_count.csv /dir/to/save/images
'''

import pickle
import os
import sys
from math import ceil

import pandas as pd
import numpy as np
from random import seed, randint

from bing import Bing


def download(
        query,
        limit=100,
        output_dir="bing_images",
        adult_filter_off=True,
        force_replace=True,
        timeout=5,
        verbose=False):

    # engine = 'bing'
    if adult_filter_off:
        adult = 'off'
    else:
        adult = 'on'

    cwd = os.getcwd()
    image_dir = os.path.join(cwd, output_dir)

    if force_replace:
        if os.path.isdir(image_dir):
            shutil.rmtree(image_dir)

    # check directory and create if necessary
    try:
        if not os.path.isdir("{}/{}/".format(cwd, output_dir)):
            os.makedirs("{}/{}/".format(cwd, output_dir))
    except:
        pass

    bing = Bing(query, limit, output_dir, adult, timeout, verbose)
    bing.run()


def main():
    # Check # of args passed 
    if len(sys.argv) != 3:
        print("Error: wrong number of args passed")
        print("Usage: python download_images.py add_count.csv dest_dir")
        exit(1)

    filename = sys.argv[1]
    dest_dir = sys.argv[2]

    # Read sim_tag dictionary
    with open("./model/sim_tag.pickle", "rb") as f:
        sim_tag = pickle.load(f)

    df = pd.read_csv(filename, index_col=0, names=["count"])
    add_count = df["count"]
    total = int(add_count.sum())
    to_be_added = int(add_count.sum())
    curr_added = 0

    seed(42)
    while True:
        idx = randint(0, add_count.shape[0])
        base = add_count.index[idx]
        sim_tags = [base] + [tag for tag in sim_tag[base] if tag in add_count.index]
        num_tags = len(sim_tags)
        limit = ceil(add_count[base] / num_tags)

        for i in range(num_tags):
            query = ' '.join(sim_tags[:i+1])
            download(
                query,
                output_dir=dest_dir,
                limit=limit,
                force_replace=False)

            add_count[sim_tags[i]] \
                = max(0, add_count[sim_tags[i]] - limit*(num_tags-i))
            print(f"Downloaded {limit} images of '{query}'")

        temp = to_be_added
        add_count = add_count.where(add_count > 0).dropna()
        to_be_added = int(add_count.sum())
        curr_added += temp - to_be_added
        print(f"[{curr_added}/{total}]")
        if to_be_added <= 0:
            break

        add_count.to_csv("download_images_log.csv", header=False)


if __name__ == "__main__":
    main()
