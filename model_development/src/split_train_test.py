'''
File: split_train_test.py
Description: split data_list.txt into test and train/val parts
'''
from random import sample
import pandas as pd

filename = pd.read_csv("./HARRISON/data_list.txt", names=["filename"], header=None)
hashtag = pd.read_csv("./HARRISON/tag_list.txt",
                      names=["labels"],
                      header=None,
                      skip_blank_lines=False).fillna("")

test_idx = sample(range(filename.shape[0]), int(filename.shape[0]*.15))

test_data = filename.loc[test_idx]
train_data = filename.loc[~filename.index.isin(test_idx)]

test_tag = hashtag.loc[test_idx]
train_tag = hashtag.loc[~filename.index.isin(test_idx)]

print(f"# of images in data_list_train.txt: {train_data.shape[0]}")
print(f"# of images in data_list_test.txt: {test_data.shape[0]}")
print(f"# of images in tag_list_train.txt: {train_tag.shape[0]}")
print(f"# of images in tag_list_test.txt: {test_tag.shape[0]}")

test_data.to_csv("./HARRISON/data_list_test.txt", header=False, index=False)
train_data.to_csv("./HARRISON/data_list_train.txt", header=False, index=False)
test_tag.to_csv("./HARRISON/tag_list_test.txt", header=False, index=False)
train_tag.to_csv("./HARRISON/tag_list_train.txt", header=False, index=False)