'''
File: model.py
Description: Abstruct class for model
'''
import pickle
from abc import ABC, abstractmethod
from keras import Model
import pandas as pd
from utils import destination


class BaseModel(ABC):

    def __init__(self, data_list, tag_list, image_dir):
        # Read files
        filename = pd.read_csv(data_list, names=["filename"], header=None)
        hashtag = pd.read_csv(
            tag_list,
            names=["labels"],
            header=None,
            skip_blank_lines=False).fillna("")

        self.target = pd.concat([filename, hashtag], axis=1)
        self.image_dir = image_dir

    @abstractmethod
    def prepare_input(self):
        pass

    @abstractmethod
    def define(self):
        self.model = Model()

    @abstractmethod
    def compile(self):
        self.model.compile()

    @abstractmethod
    def fit(self, e=1, v=2):
        self.history = self.model.fit()

    def summary(self):
        self.model.summary()

    def plot_history(self):
        print("N/A")

    def save(self, dirname, filename):
        # Save model for future use
        dest = destination(dirname, filename)
        self.model.save(dest)
        print(f"Model saved as {dest}")

    def save_history(self, dirname, filename):
        # Save history for future use
        dest = destination(dirname, filename)
        with open(dest, "wb") as f:
            pickle.dump(self.history.history, f)
        print(f"History saved as {dest}")
