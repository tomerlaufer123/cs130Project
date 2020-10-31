'''
File: keras2tflite.py
Description: Convert a keras model into a tflite format
Usage: python keras2tflite.py /path/to/keras/model
'''
from sys import argv
from os import path

try:
    path_to_keras_model = argv[1]
    if not path.exists(path_to_keras_model):
        raise FileNotFoundError
except FileNotFoundError:
    print(f"{argv[0]}: '{argv[1]}' does not exist")
    print(f"{argv[0]}: Usage: python keras2tflite.py /path/to/keras/model")
    exit(1)
except Exception:
    print(f"{argv[0]}: Usage: python keras2tflite.py /path/to/keras/model")
    exit(1)

import tensorflow as tf
from utils import destination

# Load keras model
model = tf.keras.models.load_model(path_to_keras_model)

# Convert the model
converter = tf.lite.TFLiteConverter.from_keras_model(model)
tflite_model = converter.convert()

# Save tflite model
dest_path = path_to_keras_model+".tflite"
with open(dest_path, "wb") as f:
    f.write(tflite_model)
