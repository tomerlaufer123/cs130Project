'''
File: destination.py
Description: A helper function to create a unique file name
'''
from datetime import datetime


def destination(root="", path="") -> str:
    time = datetime.now().strftime("%m%d%H%M%S")
    return f"{root}/{time}_{path}"
