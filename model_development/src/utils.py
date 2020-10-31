'''
File: utils.py
Description: helper functions
'''


# create unique destination path
def destination(root="", filename="") -> str:
    from datetime import datetime

    time = datetime.now().strftime("%m%d%H%M%S")
    return f"{root}/{time}_{filename}"


# save model
def save_models(model, root=""):
    import sys
    import tensorflow as tf

    # Convert the model
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    tflite_model = converter.convert()

    # Save keras model
    dest_path = destination(root, "keras_model")
    with open(dest_path, "wb") as f:
        f.write(model)
    print(f"tf model is saved as {dest_path}")

    # Save tflite model
    with open(dest_path+".tflite", "wb") as f:
        f.write(tflite_model)
    print(f"tflite model is saved as {dest_path}.tflite")
