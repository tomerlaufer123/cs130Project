'''
File: download_images.py
Description: This is used to download additional images.
             See `notebooks/6-additional-images.ipynb` for related info.
Usage: python download_images.py count_log.csv query_log.csv /dir/to/save/images
'''

import pickle
import os
import sys
from math import ceil
from random import uniform
import time
import signal
import traceback
import pandas as pd
import numpy as np
from google_crawler import Google

count_log = None
query_log = None
add_count = None
completed_quries = None


def eprint(*args):
    print(*args, file=sys.stderr)


def log():
    add_count.to_csv(count_log, header=False)
    completed_quries.to_csv(query_log, header=False)


def handler(sig, frame):
    global add_count
    eprint("[!] Catched SIGINT - Exiting the program")
    add_count = add_count.where(add_count > 0).dropna()
    log()
    exit(0)


def main():
    global add_count
    global completed_quries
    global count_log
    global query_log

    # Check # of args passed 
    if len(sys.argv) != 4:
        eprint("Error: wrong number of args passed")
        eprint("Usage: python download_images.py add_count.csv dest_dir")
        exit(1)

    count_log = sys.argv[1]
    query_log = sys.argv[2]
    dest_dir = sys.argv[3]

    # check directory and create if necessary
    cwd = os.getcwd()
    if not os.path.isdir("{}/{}/".format(cwd, dest_dir)):
        os.makedirs("{}/{}/".format(cwd, dest_dir))

    # Read sim_tag dictionary
    with open("misc/sim_tag.pickle", "rb") as f:
        sim_tag = pickle.load(f)

    # Read log
    df1 = pd.read_csv(count_log, index_col=0, names=["count"])
    add_count = df1["count"]

    df2 = pd.read_csv(query_log, index_col=0, names=["reached_end"])
    completed_quries = df2["reached_end"]

    total = int(add_count.sum())
    to_be_added = int(add_count.sum())
    curr_added = 0

    signal.signal(signal.SIGINT, handler)

    while True:
        if to_be_added <= 0:
            eprint(f"[=] No more queries found in {count_log}")
            exit(0)
        # All queires completed
        elif len(set(add_count.index)
                 .difference(set(completed_quries.index))) == 0:
            eprint("[=] All queries completed")
            exit(0)

        idx = int(time.time()) % add_count.shape[0]
        base = add_count.index[idx]
        sim_tags = [base] + [tag for tag in sim_tag[base] if tag in add_count.index]
        num_tags = len(sim_tags)
        limit = ceil(add_count[base] / num_tags)
        if limit == 0:
            add_count = add_count.where(add_count > 0).dropna()
            log()
            continue

        for i in range(num_tags):
            query = sim_tags[:i+1]
            if ' '.join(query) in list(completed_quries.index):
                eprint("[-] Skipping already completed query")
                time.sleep(1.3)
                continue

            # Download images
            d_count, reached_end = Google(query, limit, dest_dir).run()

            # Update log if d_count > 0
            if d_count > 0:
                completed_quries[' '.join(query)] = int(reached_end)
                for tag in query:
                    add_count[tag] = max(0, add_count[tag] - d_count)
                log()

            time.sleep(uniform(1, 2))

        temp = to_be_added
        add_count = add_count.where(add_count > 0).dropna()
        to_be_added = int(add_count.sum())
        curr_added += temp - to_be_added
        eprint(f"[{curr_added}/{total}]")


if __name__ == "__main__":
    try:
        main()
        exit(1)
    except Exception as err:
        eprint(f"[!] Error: {err}")
        eprint(traceback.format_exc())
        log()
        exit(1)
