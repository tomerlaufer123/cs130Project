'''
File: download_query.py
Description: This is used to download additional images for a single query.
             Everything is same as download_images.py except that this
             script is to download images for a single query. Use
             download_images.py if you want to download images for multiple
             queries.
Usage: python download_query.py query num count_log.csv query_log.csv /dir/to/save/images
       e.g. python download_query.py beautiful+dog 10 count_log.csv query_log.csv temp_dir
       This command download 10 images of 'beautiful dog' to temp_dir
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
    if len(sys.argv) != 6:
        print("Error: wrong number of args passed")
        print("Usage: python download_query.py query num dest_dir")
        exit(1)

    query = sys.argv[1].split("+")
    limit = int(sys.argv[2])
    count_log = sys.argv[3]
    query_log = sys.argv[4]
    dest_dir = sys.argv[5]

    # check directory and create if necessary
    cwd = os.getcwd()
    if not os.path.isdir("{}/{}/".format(cwd, dest_dir)):
        os.makedirs("{}/{}/".format(cwd, dest_dir))

    # Read log
    df1 = pd.read_csv(count_log, index_col=0, names=["count"])
    add_count = df1["count"]

    df2 = pd.read_csv(query_log, index_col=0, names=["reached_end"])
    completed_quries = df2["reached_end"]

    if ' '.join(query) in list(completed_quries.index):
        print(f"'{' '.join(query)}' already completed")
        exit(0)

    d_count, reached_end = Google(query, limit, dest_dir).run()

    if d_count > 0:
        for tag in query:
            try:
                add_count[tag] = max(0, add_count[tag] - d_count)
            except Exception:
                pass
        add_count = add_count.where(add_count > 0).dropna()
        completed_quries[' '.join(query)] = int(reached_end)

        # Log
        add_count.to_csv(count_log, header=False)
        completed_quries.to_csv(query_log, header=False)


if __name__ == "__main__":
    main()
