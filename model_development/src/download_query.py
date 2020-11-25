'''
File: download_query.py
Description: This is used to download additional images for a single query.
             Everything is same as download_images.py except that this
             script is to download images for a single query. Use
             download_images.py if you want to download images for multiple
             queries.
Usage: python download_query.py query num /dir/to/save/images
       e.g. python download_query.py beautiful+dog 10 temp_dir
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
    if len(sys.argv) != 4:
        print("Error: wrong number of args passed")
        print("Usage: python download_query.py query num dest_dir")
        exit(1)

    query = sys.argv[1].split("+")
    limit = int(sys.argv[2])
    dest_dir = sys.argv[3]
    filename = "log/download_count_log.csv"

    # check directory and create if necessary
    cwd = os.getcwd()
    if not os.path.isdir("{}/{}/".format(cwd, dest_dir)):
        os.makedirs("{}/{}/".format(cwd, dest_dir))

    # Read log
    with open("log/download_query_log") as f:
        completed_quries = f.read().split('\n')
    df = pd.read_csv(filename, index_col=0, names=["count"])
    add_count = df["count"]

    d_count, reached_end = Google(query, limit, dest_dir).run()
    for tag in query:
        add_count[tag] = max(0, add_count[tag] - d_count)

    # Log
    add_count.to_csv(filename, header=False)
    if reached_end:
        with open("log/download_query_log", "w") as f:
            f.writelines("%s\n" % query for query in completed_quries)


if __name__ == "__main__":
    main()
