'''
File: model_single.py
Description: Class for single_output model
'''
from keras.preprocessing.image import ImageDataGenerator
from keras.layers import Dense, Activation, Flatten, Dropout, Conv2D, MaxPooling2D
from keras.models import Sequential
from keras import optimizers
from keras.callbacks import EarlyStopping
import numpy as np
import pandas as pd
from sklearn.utils import shuffle
import matplotlib.pyplot as plt
from PIL import ImageFile

from utils import destination
from model import BaseModel

ImageFile.LOAD_TRUNCATED_IMAGES = True


class SingleOutput(BaseModel):

    def __init__(self, data_list, tag_list, image_dir, hashtag="./HARRISON/hashtags.txt"):
        # Read hashtags
        with open(hashtag) as f:
            # Read tag_list
            hashtags = f.read().split('\n')
        self.hashtags = hashtags[:-1]
        self.num_hashtags = len(self.hashtags)

        super().__init__(data_list, tag_list, image_dir)

    def prepare_input(self):
        self.target["labels"] = self.target["labels"].apply(lambda x: x.split(" "))
        num_images = self.target.shape[0]
        new_target = shuffle(self.target, random_state=42)
        new_target.index = range(num_images)

        train_idx = int(num_images * .80)

        # Create train data generator
        datagen = ImageDataGenerator(rescale=1./255.)
        self.train_generator = datagen.flow_from_dataframe(
            dataframe=new_target[:train_idx],
            directory=self.image_dir,
            x_col="filename",
            y_col="labels",
            batch_size=32,
            seed=42,
            shuffle=True,
            class_mode="categorical",
            classes=self.hashtags,
            target_size=(100, 100))

        self.val_generator = datagen.flow_from_dataframe(
            dataframe=new_target[train_idx:],
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
        self.step_size_val = self.val_generator.n//self.val_generator.batch_size

    # Define model
    def define(self, a=1):
        # Define model

        if a == 1:
            self.model = Sequential()
            self.model.add(Conv2D(32, (3, 3), padding='same', input_shape=(100, 100, 3)))
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
        elif a == 2:
            self.model = Sequential()
            self.model.add(Conv2D(32, kernel_size=(5, 5), strides=(1, 1),
                 activation='relu',
                 input_shape=(100, 100, 3)))
            self.model.add(MaxPooling2D(pool_size=(2, 2), strides=(2, 2)))
            self.model.add(Conv2D(64, (5, 5), activation='relu'))
            self.model.add(MaxPooling2D(pool_size=(2, 2)))
            self.model.add(Flatten())
            self.model.add(Dense(1000, activation='relu'))
            self.model.add(Dense(self.num_hashtags, activation='sigmoid'))

    # Compile model
    def compile(self):
        # Compile model
        self.model.compile(
            optimizers.rmsprop(lr=0.0001, decay=1e-6),
            loss="binary_crossentropy",
            metrics=["categorical_accuracy"])

    def fit(self, e=1, v=1):
        callback = EarlyStopping(
            monitor="val_loss",
            patience=1,
            restore_best_weights=True)

        self.history = self.model.fit_generator(
            generator=self.train_generator,
            steps_per_epoch=self.step_size_train,
            validation_data=self.val_generator,
            validation_steps=self.step_size_val,
            callbacks=[callback],
            epochs=e,
            verbose=v)

    def plot_history(self):
        fig, axs = plt.subplots(1, 2, figsize=(10, 5))
        metric = ["loss", "categorical_accuracy"]

        for idx in range(len(metric)):
            axs[idx].plot(self.history.history[metric[idx]], label="train")
            axs[idx].plot(self.history.history[f"val_{metric[idx]}"], label="validation")
            axs[idx].set(ylabel=metric[idx], xlabel="epochs")

        fig.suptitle("Learning History")
        plt.legend(loc="center right",
                   bbox_to_anchor=(0, 0, 1, 1),
                   bbox_transform=plt.gcf().transFigure)

        plt.show()

    def predict(self, generator):
        step_size = generator.n // generator.batch_size
        return self.model.predict(generator, steps=step_size)
