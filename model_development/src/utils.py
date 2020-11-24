'''
File: utils.py
Description: helper functions
'''


# create unique destination path
def destination(root="", filename="") -> str:
    from datetime import datetime
    from os import path

    time = datetime.now().strftime("%m%d%H%M%S")
    return path.join(root, f"{time}_{filename}")


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


# Display image generatated images
# Make sure gen.batch_size >= row * col for a nicer display
def show_images(gen, data_list, tag_list, row=5, col=4, categorical=True):
    from keras.preprocessing.image import ImageDataGenerator
    import matplotlib.pyplot as plt

    file2tag = dict(zip(data_list, tag_list))
    if categorical:
        images = gen.next()[0][:row*col]
    else:
        images = gen.next()[:row*col]

    start = (gen.batch_index-1) * gen.batch_size
    start = gen.n - gen.batch_size if start < 0 else start
    idxs = gen.index_array[start: start+gen.batch_size]

    fig, axs = plt.subplots(
        row,
        col,
        figsize=(24, 30),
        constrained_layout=True)

    axs = axs.flat
    for ax in axs[gen.batch_size:]:
        ax.remove()

    for idx, ax, image in zip(idxs, axs, images):
        fname = gen.filenames[idx]
        ax.set_title(f"{fname}")
        ax.set_xticks([])
        ax.set_yticks([])
        tag = '\n'.join(['#' + h for h in file2tag[fname]])
        props = dict(boxstyle='round', facecolor='pink', alpha=0.7)
        ax.text(0.05, 0.95, tag, transform=ax.transAxes, fontsize=15,
                verticalalignment='top', bbox=props)
        ax.imshow(image)

    fig.set_constrained_layout_pads(w_pad=0, h_pad=0.1, hspace=0, wspace=0)
    plt.show()
