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

2. Flatten ```instagram_dataset/```, i.e. move all the images in the subdirectories to ```instagram_dataset/git ``` using the following commands:
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

    The directory layout should look like:
    ```
    .
    ├──model_development/
    │   ├──HARRISON/
    │   │   ├──images/
    │   │   │   ├──amazing_image_4.jpg
    │   │   │   ...
    │   │   ├──instagram_datase/
    │   │   ├──data_list.txt
    │   │   └──tag_list.txt
    │   ...
    ...
    ```

## Source Description
1. ```flatten.py```

2. ```prepare_data.py```

3. ```destination.py```

4. ```train.py```

5. ```test.py```


## Notebooks
This is where we do our experiments.
...

## Reference
- Minseok Park and Hanxiang Li and Junmo Kim (2016). HARRISON: A Benchmark on HAshtag Recommendation for Real-world Images in Social Networks. https://github.com/minstone/HARRISON-Dataset. Eprint: arXiv:1605.05054