#!/bin/bash

start_seconds="$(date +%s)"
echo "Welcome to the initialization script."

ping_result="$(ping -c 2 8.8.4.4 2>&1)"
if [[ $ping_result != *bytes?from* ]]; then
    echo "Network connection unavailable. Try again later."
    exit 1
fi

apt_packages=(
    git
    build-essential
    python-dev
    python-numpy
    swig
    python-wheel
    zip
    zlib1g-dev
    awscli
)

sudo apt-get update
sudo apt-get -y upgrade

echo "Installing apt-get packages..."
sudo apt-get install -y ${apt_packages[@]}
sudo apt-get clean


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
# DRIVER_VERSION='361.45.11'
# mkdir ~/tmp
# cd ~/tmp
# wget http://us.download.nvidia.com/XFree86/Linux-x86_64/$DRIVER_VERSION/NVIDIA-Linux-x86_64-$DRIVER_VERSION.run
# if [ -f NVIDIA-Linux-x86_64-$DRIVER_VERSION.run ]; then
#     sudo bash NVIDIA-Linux-x86_64-$DRIVER_VERSION.run -a -q
# else
#     echo 'Error: Failed to download driver.'
#     exit 2
# fi
# cd ~
# if [ $(nvidia-smi -q |grep 'Product\ Name' |grep -c $PRODUCT_NAME) != 1 ]; then
#     echo 'Error: Product Name does not matched.'
#     exit 3
# fi



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
cd ~
aws s3 cp s3://mjm-image-classifier/cudnn-7.0-linux-x64-v4.0-prod.tgz . --region us-east-1
cp ~/cudnn-7.0-linux-x64-v4.0-prod.tgz ~/tmp
cd ~/tmp
tar xvzf cudnn-7.0-linux-x64-v4.0-prod.tgz
sudo cp cuda/include/cudnn.h /usr/local/cuda/include
sudo cp cuda/lib64/libcudnn* /usr/local/cuda/lib64
cd ~


## Clean up
cd ~
rm -rf ./tmp

## f) Finish configure
echo 'export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/usr/local/cuda/lib64"' >> ~/.bashrc
echo 'export CUDA_HOME=/usr/local/cuda' >> ~/.bashrc


#install anaconda
anaconda=Anaconda2-4.0.0-Linux-x86_64.sh
cd ~
if [ ! -f $anaconda ]
    then
        echo "No Anaconda install file pre-loaded. Downloading Anaconda"
        echo "NOTE: downloading and installing Anaconda2-4.0.0-Linux-x86_64.sh"
        wget --quiet http://repo.continuum.io/archive/$anaconda
fi
chmod +x $anaconda

./$anaconda

conda_path=/home/ubuntu/anaconda2/bin
echo $conda_path

cat >> ~/.bashrc << END
PATH=:$conda_path:\$PATH
END


# Install Java 8 (required for Bazel)
sudo add-apt-repository -y ppa:webupd8team/java
sudo apt-get -y update
sudo apt-get install -y oracle-java8-installer


# Install Bazel
echo "deb http://storage.googleapis.com/bazel-apt stable jdk1.8" | sudo tee /etc/apt/sources.list.d/bazel.list
curl https://storage.googleapis.com/bazel-apt/doc/apt-key.pub.gpg | sudo apt-key add -
sudo apt-get -y update && sudo apt-get install -y bazel
sudo apt-get upgrade -y bazel

# Reboot at this point