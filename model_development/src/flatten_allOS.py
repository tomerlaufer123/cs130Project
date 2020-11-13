'''
File: flatten.py
Description: flatten a directory structure
'''
import os
import sys
import shutil

SRC_DIR = os.path.join(".","HARRISON","instagram_dataset")
DEST_DIR = os.path.join(".","HARRISON","images")

for root, dirs, files in os.walk(SRC_DIR):
    for filename in files:
        # Ignore .DS_Store
        if filename == ".DS_Store":
            continue
        # Get source path
        source_path = os.path.join(root, filename)
        # Generate a new file name
        new_filename = root.split(os.sep)[-1] + "_" + filename        
        # Set destination path
        destination_path = os.path.join(DEST_DIR, new_filename)
        # Copy file from source to destination
        shutil.copy(source_path, destination_path)
