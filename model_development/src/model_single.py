'''
File: model_single.py
Description: Class for single_output model
'''
from keras.preprocessing.image import ImageDataGenerator
from keras.layers import Dense, Activation, Flatten, Dropout, Conv2D, MaxPooling2D
from keras.models import Sequential
from keras import optimizers
import numpy as np
import pandas as pd
from sklearn.utils import shuffle
import matplotlib.pyplot as plt
from PIL import ImageFile

from utils import destination
from model import BaseModel

ImageFile.LOAD_TRUNCATED_IMAGES = True


class SingleOutput(BaseModel):

    def __init__(self, data_list, tag_list, image_dir, hashtag_list):
        # Read hashtags
        with open(hashtag_list) as f:
            # Read tag_list
            hashtags = f.read().split('\n')
        self.hashtags = hashtags[:-1]
        self.num_hashtags = len(hashtags)

        super().__init__(data_list, tag_list, image_dir)

    def prepare_input(self):
        self.target["labels"] = self.target["labels"].apply(lambda x: x.split(" "))
        new_target = shuffle(self.target, random_state=42)

        # Create train data generator
        datagen = ImageDataGenerator(rescale=1./255.)
        self.train_generator = datagen.flow_from_dataframe(
            dataframe=new_target,
            directory=self.image_dir,
            x_col="filename",
            y_col="labels",
            batch_size=32,
            seed=42,
            shuffle=True,
            class_mode="categorical",
            classes=self.hashtags,
            target_size=(100, 100))

        self.step_size_train = self.train_generator.n//self.train_generator.batch_size

    # Define model
    def define(self):
        # Define model
        self.model = Sequential()
        self.model.add(Conv2D(32, (3, 3), padding='same', input_shape=(100,100,3)))
        self.model.add(Activation('relu'))
        self.model.add(Conv2D(32, (3, 3)))
        self.model.add(Activation('relu'))
        self.model.add(MaxPooling2D(pool_size=(2, 2)))
        self.model.add(Dropout(0.25))
        self.model.add(Conv2D(64, (3, 3), padding='same'))
        self.model.add(Activation('relu'))
        self.model.add(Conv2D(64, (3, 3)))
        self.model.add(Activation('relu'))
        self.model.add(MaxPooling2D(pool_size=(2, 2)))
        self.model.add(Dropout(0.25))
        self.model.add(Flatten())
        self.model.add(Dense(512))
        self.model.add(Activation('relu'))
        self.model.add(Dropout(0.5))
        self.model.add(Dense(self.num_hashtags, activation='sigmoid'))

    # Compile model
    def compile(self):
        # Compile model
        self.model.compile(
            optimizers.rmsprop(lr=0.0001, decay=1e-6),
            loss="binary_crossentropy",
            metrics=["accuracy"])

    def fit(self, e=1, v=2):
        self.history = self.model.fit_generator(
            generator=self.train_generator,
            steps_per_epoch=STEP_SIZE_TRAIN,
            epochs=e,
            verbose=v)

    def plot_history(self):
        fig, axs = plt.subplots(1, 2, figsize=(15, 5))
        metric = ["loss", "accuracy"]

        for idx in range(len(metric)):
            axs[idx].plot(history.history[metric[idx]], label="train")
            axs[idx].plot(history.history[f"val_{metric[idx]}"], label="validation")
            axs[idx].set(ylabel=metric[idx], xlabel="epochs")

        fig.suptitle("Learning History")
        plt.legend(loc="center right",
                   bbox_to_anchor=(0, 0, 1, 1),
                   bbox_transform=plt.gcf().transFigure)

        plt.show()
