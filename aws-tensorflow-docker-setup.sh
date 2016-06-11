#!/bin/bash

DRIVER_VERSION='361.45.11'
PRODUCT_NAME='K520'


# Prepare nVidia Driver

if [ -d ~/tmp ]; then
    rm -rf ~/tmp
fi


## Install basic packages
sudo apt-get update
sudo apt-get install -y make build-essential libssl-dev zlib1g-dev libbz2-dev git libreadline-dev \
    libsqlite3-dev wget curl llvm libncurses5-dev libncursesw5-dev linux-image-extra-`uname -r`


## Check whether the host has GPU Device
gpu_count = $(lspci |grep -i VGA|grep -i -c nVidia)

if [ $gpu_count == 0 ]; then
    echo 'Error: Can not found GPU device on the host.'
    exit 1
fi


## Install nVidia Driver
mkdir ~/tmp
cd ~/tmp
wget http://us.download.nvidia.com/XFree86/Linux-x86_64/$DRIVER_VERSION/NVIDIA-Linux-x86_64-$DRIVER_VERSION.run
if [ -f NVIDIA-Linux-x86_64-$DRIVER_VERSION.run ]; then
    sudo bash NVIDIA-Linux-x86_64-$DRIVER_VERSION.run -a -q
else
    echo 'Error: Failed to download driver.'
    exit 2
fi
cd ~
if [ $(nvidia-smi -q |grep 'Product\ Name' |grep -c $PRODUCT_NAME) != 1 ]; then
    echo 'Error: Product Name does not matched.'
    exit 3
fi


## d) Install CUDA-toolkit 7.5
cd ~/tmp
wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64/cuda-repo-ubuntu1404_7.5-18_amd64.deb
if [ -f cuda-repo-ubuntu1404_7.5-18_amd64.deb ]; then
    sudo dpkg -i cuda-repo-ubuntu1404_7.5-18_amd64.deb
    sudo apt-get update
    sudo apt-get -y install cuda
else
    echo 'Error: Failed to download cuda-repo-ubuntu1404_7.5-18_amd64.deb'
    exit 4
fi
cd ~

## e) Install CuDNN v4
if [ -f ~/cudnn-7.0-linux-x64-v4.0-prod.tgz ]; then
    cp ~/cudnn-7.0-linux-x64-v4.0-prod.tgz ~/tmp
    cd ~/tmp
    tar xvzf cudnn-7.0-linux-x64-v4.0-prod.tgz
    sudo cp cuda/include/cudnn.h /usr/local/cuda/include
    sudo cp cuda/lib64/libcudnn* /usr/local/cuda/lib64
    cd ~
else
    echo 'Error: Can not found CuDNN.'
    exit 5
fi

## f) Finish configure
echo 'export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda/lib64"' >> ~/.bashrc
echo 'export CUDA_HOME=/usr/local/cuda' >> ~/.bashrc

## Clean up
cd ~
rm -rf ./tmp


# Install docker
# NOTE: you'll have to exit out of ubuntu user and log back in again in order to be able to use `docker` command without sudo
curl -fsSL https://get.docker.com/ | sh

sudo usermod -aG docker ubuntu


# Install nvidia-docker and nvidia-docker-plugin
wget -P /tmp https://github.com/NVIDIA/nvidia-docker/releases/download/v1.0.0-rc.2/nvidia-docker_1.0.0.rc.2-1_amd64.deb
sudo dpkg -i /tmp/nvidia-docker*.deb && rm /tmp/nvidia-docker*.deb
