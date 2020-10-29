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
    Note: your current directory should be in ```model_development/```\
    You can activate the environment by using the command:
    ```
    conda activate youreit
    ```
3. Download [HARRISON dataset](https://github.com/minstone/HARRISON-Dataset). The dataset is in a torrent file. If you don't have a torrent client, you can install [qBittorrent](https://www.qbittorrent.org/download.php). If you don't know how to download and open a torrent file, [this tutorial](https://www.wikihow.com/Download-and-Open-Torrent-Files) might be helpful. Once you download the dataset, save it under ```dataset/```.


## Notebooks
This is where we do our experiments.
1. Data Preparation

2. 

## Reference
- Minseok Park and Hanxiang Li and Junmo Kim (2016). HARRISON: A Benchmark on HAshtag Recommendation for Real-world Images in Social Networks. https://github.com/minstone/HARRISON-Dataset. Eprint: arXiv:1605.05054
