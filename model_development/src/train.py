'''
File: train.py
Description: Train a model and save a model to disk.
'''

from keras import preprocessing, Input, Model, regularizers, optimizers
from keras.preprocessing.image import ImageDataGenerator
from keras.layers import Dense, Activation, Flatten, Dropout
from keras.layers import Conv2D, MaxPooling2D
from keras.models import load_model
import pandas as pd
import numpy as np
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.utils import shuffle

from PIL import ImageFile
ImageFile.LOAD_TRUNCATED_IMAGES = True

from utils import destination

DATA_LIST = "./HARRISON/data_list.txt"
TAG_LIST = "./HARRISON/1113124810_tag_list.txt"
IMAGE_DIR = "./HARRISON/images"

# Read files
filename = pd.read_csv(DATA_LIST, names=["filename"], header=None)
hashtag = pd.read_csv(TAG_LIST, names=["labels"], header=None)

# Convert filenames from "instagram_dataset/xxx/yyy.jpg" to "xxx_yyy.jpg"
filename["filename"]\
    = filename["filename"].apply(lambda x: "_".join(x.split("/")[1:]))

# Concatenate filname and labels
target = pd.concat([filename, hashtag], axis=1)

# Use vectorizer to generate a one-hot encoding
vectorizer = CountVectorizer()
X = vectorizer.fit_transform(target["labels"])
columns = vectorizer.get_feature_names()
X_df = pd.DataFrame(X.toarray(), columns=columns)

# Combine hashtag encodings with file names
target = pd.concat([target, X_df], axis=1)
target = shuffle(target, random_state=42)

num_images = target.shape[0]
num_hashtags = X_df.shape[1]

# Instanciate a data generator
datagen = ImageDataGenerator(rescale=1./255.)

# Create train data generator
train_generator = datagen.flow_from_dataframe(
        dataframe=target,
        directory=IMAGE_DIR,
        x_col="filename",
        y_col=columns,
        batch_size=32,
        seed=42,
        shuffle=True,
        class_mode="raw",
        target_size=(100, 100)
    )

# Define model
inp = Input(shape=(100, 100, 3))
x = Conv2D(32, (3, 3), padding='same')(inp)
x = Activation('relu')(x)
x = Conv2D(32, (3, 3))(x)
x = Activation('relu')(x)
x = MaxPooling2D(pool_size=(2, 2))(x)
x = Dropout(0.25)(x)
x = Conv2D(64, (3, 3), padding='same')(x)
x = Activation('relu')(x)
x = Conv2D(64, (3, 3))(x)
x = Activation('relu')(x)
x = MaxPooling2D(pool_size=(2, 2))(x)
x = Dropout(0.25)(x)
x = Flatten()(x)
x = Dense(512)(x)
x = Activation('relu')(x)
x = Dropout(0.5)(x)
output = []
for i in range(num_hashtags):
    output.append(Dense(1, activation='sigmoid')(x))

model = Model(inp, output)

# Compile model
model.compile(optimizers.rmsprop(
        lr=0.0001,
        decay=1e-6),
        loss=["binary_crossentropy" for i in range(num_hashtags)],
        metrics=["accuracy"])


def generator_wrapper(generator):
    for batch_x, batch_y in generator:
        yield (batch_x, [batch_y[:, i] for i in range(num_hashtags)])


step_size_train = train_generator.n//train_generator.batch_size


model.fit_generator(
        generator=generator_wrapper(train_generator),
        steps_per_epoch=step_size_train,
        epochs=1,
        verbose=0)

# Save model for future use
model.save(destination("../model", "keras_model"))
