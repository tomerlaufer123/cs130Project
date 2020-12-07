# You're It!

## Overview
Team project for CS130 Software Engineering Fall 2020.

## Team Member
- Shreya Raman
- Karl Danielsen
- Takashi Joubert
- Tomer Laufer
- Sam Pando
- Rio Sonoyama

## Repository Structure

Here is an overview of our repository structure.
- `hashtag_app`
    - `README.md`: A brief description of our flutter app and some of the relevant files
    - `.gitignore`
    - `.metadata`
    - `pubspec.lock`
    - `pubspec.yaml`
    - `ios`: iOS project version
    - `android`: Android project version
    - `assets`: Contains completed tflite model as well as test files and images
    - `test`: Project files for automated testing
        - `api_test.dart`: project test cases
    - `lib`: Dart project apis
        - `main.dart`: main loop for the project
        - `api_call.dart`: 
        - `hashtag_list.dart`
        - `history.dart`
        - `homepage.dart`
        - `list_item.dart`
        - `similar_images.dart`
        - `trending.dart`
    - `doc/api`: The API documentation for our project files
- `model_development`
    - `README.md`: A brief documentation for model development process
    - `environment.yml`: Conda environment configuration
    - `sample_predictions.png`
    - `model`
        - `2.4_balanced_2_keras_model_5_mlsol.tflite`
    - `notebooks`
        - `1-base-model.jpynb`: Base model development
        - `2-balance-data.ipynb`: Handle imbalance in HARRISON dataset
        - `2.1-balance-data.ipynb`: Oversampling
        - `2.2-balance-data.ipynb`: Tag substitution using NLTK
        - `2.4-balance-data.ipynb`: Tag clustering
        - `3-improve-hashtags.ipynb`: True value improvement
        - `4-mlsol.ipynb`: Data augmentation
        - `5-single-output-model.ipynb`: Final model development 
        - `6-additional-images.ipynb`: Web-scraping for additional images
        - `8-create-dataset.ipynb`
        - `9-evaluation.ipynb`: Evaluations of different models
    - `src`
        - `data_balance.py`: Fix data imblance
        - `google_crawler.py`: Web-scrapping wrapper script (multiple queries)
        - `download_images.py`: A class for scraping
        - `download_query.py`: Web-scrapping wrapper script (single query)
        - `mlsol.py`: Data augmentation
        - `model.py`: Abstract class for model
        - `model_multi.py`: Base model
        - `model_single.py`: Final model
        - `train.py`: Used to train our models
        - `utils.py`: Implementation of utility functions
        - `keras2tflite.py`: Converts a keras model to tflite format
        - `split_train_test.py`: Split HARRISON dataset into train/test datasets
        - `flatten_allOS.py`: Reformats directory structure of HARRISON images
