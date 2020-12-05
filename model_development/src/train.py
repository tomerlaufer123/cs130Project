'''
File: train.py
Description: Train a model and save a model to disk.
Usage: python train.py /path/to/data_list /path/to/tag_list /path/to/images_dir
'''

import sys
import os
import time
# from model_multi import MultiOutput
from model_single import SingleOutput


def sep(string, pos):
    m = 50 - len(string)
    if not pos:
        ret = string + ' ' + '#' * m
    else:
        ret = '#' * m + ' ' + string + '\n'
    return ret


def main():
    # Check # of args passed 
    if len(sys.argv) != 4:
        print("Error: wrong number of args passed")
        print("Usage: python train.py data_list tag_list image_dir")
        exit(1)

    data_list = sys.argv[1]
    tag_list = sys.argv[2]
    image_dir = sys.argv[3]

    # Confirm args are correct
    print(f"data_list = {data_list}")
    print(f"tag_list = {tag_list}")
    print(f"image_dir = {image_dir}")
    print("Are these paths correct? [y/n] ", end="")
    
    inp = str(input())
    if inp != 'y':
        print("Exiting the program...")
        exit(0)
    print("")

    # model = MultiOutput(
    #     tag_list=tag_list,
    #     data_list=data_list,
    #     image_dir=image_dir)

    model = SingleOutput(
        tag_list=tag_list,
        data_list=data_list,
        image_dir=image_dir)

    print(sep("PREPARE INPUT", 0))
    s = time.time()
    model.prepare_input()
    print(sep(f"{time.time()-s:.2f} SEC", 1))

    print(sep("DEFINE MODEL", 0))
    s = time.time()
    model.define()
    print(sep(f"{time.time()-s:.2f} SEC", 1))

    print(sep("COMPILE MODEL", 0))
    s = time.time()
    model.compile()
    model.summary()
    print(sep(f"{time.time()-s:.2f} SEC", 1))

    print(sep("FIT MODEL", 0))
    s = time.time()
    model.fit(e=100)
    print(sep(f"{time.time()-s:.2f} SEC", 1))

    print(sep("SAVE MODEL", 0))
    s = time.time()
    model.save(os.path.join(".", "model"), "keras_model")
    print(sep(f"{time.time()-s:.2f} SEC", 1))


if __name__ == "__main__":
    main()
