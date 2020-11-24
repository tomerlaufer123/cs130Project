'''
File: download_images.py
Description: This is used to download additional images.
             See `notebooks/6-additional-images.ipynb` for related info.
Usage: python download_images.py add_count.csv /dir/to/save/images
'''

import pickle
import os
import sys
from math import ceil
from random import uniform
import time
import pandas as pd
import numpy as np
from google_crawler import Google


def main():
    # Check # of args passed 
    if len(sys.argv) != 3:
        print("Error: wrong number of args passed")
        print("Usage: python download_images.py add_count.csv dest_dir")
        exit(1)

    filename = sys.argv[1]
    dest_dir = sys.argv[2]

    # check directory and create if necessary
    cwd = os.getcwd()
    if not os.path.isdir("{}/{}/".format(cwd, dest_dir)):
        os.makedirs("{}/{}/".format(cwd, dest_dir))

    # Read sim_tag dictionary
    with open("misc/sim_tag.pickle", "rb") as f:
        sim_tag = pickle.load(f)

    # Read log
    with open("log/download_query_log") as f:
        completed_quries = f.read().split('\n')
    df = pd.read_csv(filename, index_col=0, names=["count"])

    add_count = df["count"]
    total = int(add_count.sum())
    to_be_added = int(add_count.sum())
    curr_added = 0

    while True:
        # All queires completed
        if len(set(add_count.index).difference(set(completed_quries))) == 0:
            print("[=] All queries completed")
            exit(0)

        idx = int(time.time()) % add_count.shape[0]
        base = add_count.index[idx]
        sim_tags = [base] + [tag for tag in sim_tag[base] if tag in add_count.index]
        num_tags = len(sim_tags)
        limit = ceil(add_count[base] / num_tags)

        for i in range(num_tags):
            query = sim_tags[:i+1]
            if query in completed_quries:
                continue
            # q_tag = ['#'+q for q in query]
            # print(f"[ ] Collecting {limit} image srouces for: {' '.join(q_tag)}")
            d_count, reached_end = Google(query, limit, dest_dir).run()
            # print(f"[+] Downloaded {d_count} images for: {' '.join(q_tag)}")

            if reached_end:
                completed_quries.append(' '.join(query))

            for tag in query:
                add_count[tag] = max(0, add_count[tag] - d_count)
            t = uniform(1, 2)
            time.sleep(t)

        temp = to_be_added
        add_count = add_count.where(add_count > 0).dropna()
        to_be_added = int(add_count.sum())
        curr_added += temp - to_be_added
        print(f"[{curr_added}/{total}]")

        # Log
        add_count.to_csv(filename, header=False)
        if reached_end:
            with open("log/download_query_log", "w") as f:
                f.writelines("%s\n" % query for query in completed_quries)

        if to_be_added <= 0:
            print("[=] All queries completed")
            exit(0)


if __name__ == "__main__":
    main()
