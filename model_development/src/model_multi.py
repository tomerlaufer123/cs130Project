'''
File: model_multi.py
Description: Class for multi-outputs model
'''
from keras.preprocessing.image import ImageDataGenerator
from keras.layers import Dense, Activation, Flatten, Dropout, Conv2D, MaxPooling2D
from keras import Model, Input, optimizers
import numpy as np
import pandas as pd
from sklearn.feature_extraction.text import CountVectorizer
from sklearn.utils import shuffle
from PIL import ImageFile

from utils import destination
from model import BaseModel

ImageFile.LOAD_TRUNCATED_IMAGES = True


class MultiOutput(BaseModel):

    def __init__(self, data_list, tag_list, image_dir):
        super().__init__(data_list, tag_list, image_dir)

    def prepare_input(self):
        # Use vectorizer to generate a one-hot encoding
        vectorizer = CountVectorizer(binary=True)
        y = vectorizer.fit_transform(self.target["labels"])
        self.columns = vectorizer.get_feature_names()
        y_df = pd.DataFrame(y.toarray(), columns=self.columns)

        # Combine hashtag encodings with file names
        new_target = pd.concat([self.target, y_df], axis=1)
        new_target = shuffle(new_target, random_state=42)

        self.num_hashtags = y_df.shape[1]

        # Create train data generator
        datagen = ImageDataGenerator(rescale=1./255.)
        self.train_generator = datagen.flow_from_dataframe(
            dataframe=new_target,
            directory=self.image_dir,
            x_col="filename",
            y_col=self.columns,
            batch_size=32,
            seed=42,
            shuffle=True,
            class_mode="raw",
            target_size=(100, 100))

        self.step_size_train = self.train_generator.n//self.train_generator.batch_size

    # Define model
    def define(self):
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
        for i in range(self.num_hashtags):
            output.append(Dense(1, activation='sigmoid', name=f"out_{self.columns[i]}")(x))
            
        self.model = Model(inp, output)

    # Compile model
    def compile(self):
        # Compile model
        self.model.compile(
                optimizers.rmsprop(lr=0.0001, decay=1e-6),
                loss=["binary_crossentropy" for i in range(self.num_hashtags)],
                metrics=["accuracy"])

    def fit(self, e=1, v=2):
        self.history = self.model.fit_generator(
            generator=generator_wrapper(self.train_generator),
            steps_per_epoch=self.step_size_train,
            epochs=e,
            verbose=v)

    def generator_wrapper(self, generator):
        for batch_x, batch_y in generator:
            yield (batch_x, [batch_y[:, i] for i in range(self.num_hashtags)])
