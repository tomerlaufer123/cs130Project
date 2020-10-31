# Hashtag Generator

## Overview
We develop a TensorFlow model that auto-generates hashtags based on the input image.

## Main Contributers
- Tomer Laufer
- Rio Sonoyama

## Environment Setup

1.  We use anaconda for package management and creating a python environment. Please refer to [this documentation](https://docs.anaconda.com/anaconda/install/) for installing anaconda on your local machine. Alternatively, you can install [miniconda](https://docs.conda.io/en/latest/miniconda.html).

2. Once conda is installed, use the following command to create the environment:
    ```
    conda env create -f environment.yml
    ```
    Note: your current directory should be ```model_development/```. 
    
    You can activate the environment by using the command:
    ```
    conda activate youreit
    ```


## Getting Started

1. Download [HARRISON dataset](https://github.com/minstone/HARRISON-Dataset). The dataset is in a torrent file. If you don't have a torrent client, you can install [qBittorrent](https://www.qbittorrent.org/download.php). If you don't know how to download and open a torrent file, [this tutorial](https://www.wikihow.com/Download-and-Open-Torrent-Files) might be helpful. Once you download the dataset, move the untared directory (```HARRISON/```) under the current directly.
    ```
    .
    ├──model_development/
    │   ├──HARRISON/
    │   ...
    ...
    ```

2. Flatten ```HARRISON/instagram_dataset/```, i.e. move all the images in the subdirectories to ```HARRISON/images ``` using the following commands:
    ```
    rm -rf ./HARRISON/images
    mkdir -p ./HARRISON/images
    python ./src/flatten.py
    ```
    You can confirm that ```HARRISON/images/``` contains **57383** images:
    ```
    ls ./HARRISON/images | wc -l
    ```
    Output: 57383

    Once you confirm that all the images are successfully copied, you can remove ```HARRISON/instagram_dataset/```:
    ```
    rm -rf ./HARRISON/instagram_dataset
    ```


    The directory layout should look like:
    ```
    .
    ├──model_development/
    │   ├──HARRISON/
    │   │   ├──images/
    │   │   │   ├──amazing_image_4.jpg
    │   │   │   ...
    │   │   ├──data_list.txt
    │   │   └──tag_list.txt
    │   ...
    ...
    ```
    Note: Because ```HARRISON/``` is large, we do not share it in this repository. Instead, we uploaded only a small portion of the images so that they can be used in notebook previews.

## Source Description
1. **utils.py**
    - ```destination(root="", filename="") -> str```
        - ```root``` (str): a relative path to a target dir
        - ```filename``` (str): filename
        
        This function is used to generate a unique destination filename when saving a python object. For example, 
        ```destination("./model", "filename")``` returns a string ```".model/YYMMDDhhmmss_filename"``` where ```YYMMDDhhmmss``` represents the time when the function is called.

    - ```save_models(model, root="", from_nb=True)```
        - ```model``` (tf.keras.models): a keras model to be saved to the disc
        - ```root``` (str): a relative path to a target dir

        This function saves ```model``` as both keras model and tflite model to the disc. The keras and tflite models are saved as ```root/YYMMDDhhmmss_keras_model``` and ```root/YYMMDDhhmmss_keras_model.tflite```, respectively.

2. **flatten.py**

    ```
    Usage: python flatten.py
    ```
    This script is used to change the directory layout of ```HARRISON/```. The images in ```HARRISON\``` are organized as following:
    ```
    HARRISON/
    ├──instagram_dataset/
    │   ├──amazing/
    │   │   ├──image_4.jpg
    │   │   ...
    │   ├──beach/
    │   ...
    ├──data_list.txt
    └──tag_list.txt
    ```
    When you run this script from the parent directory of ```HARRISON/```, ```HARRISON/images/``` is created such that all the images are located right under ```HARRISON/images/```.
    
3. **keras2tflite.py**

    ```
    Usage: python keras2tflite.py /path/to/keras/model
    ```
    This script is used to convert a keras model to a tflite model. The tflite is then saved as ```/path/to/keras/model.tflite```.
    
4. **train.py**


## Notebooks
This is where we do our experiments.

- **1-base-model.jpynb**
    
    A base model is created. ```./model/1031004017_keras_model.tflite``` can be deployed on a flutter app.


## Reference
- Minseok Park and Hanxiang Li and Junmo Kim (2016). HARRISON: A Benchmark on HAshtag Recommendation for Real-world Images in Social Networks. https://github.com/minstone/HARRISON-Dataset. Eprint: arXiv:1605.05054