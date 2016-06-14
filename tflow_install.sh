#!/usr/bin/env bash

start_seconds="$(date +%s)"
echo "Welcome to the initialization script."

ping_result="$(ping -c 2 8.8.4.4 2>&1)"
if [[ $ping_result != *bytes?from* ]]; then
    echo "Network connection unavailable. Try again later."
    exit 1
fi

# install git
apt_packages=(
    git
    build-essential
	python-pip
	libfreetype6-dev
	libxft-dev
	libncurses-dev
	libopenblas-dev
	gfortran
	python-matplotlib
	libblas-dev
	liblapack-dev
	libatlas-base-dev
	python-dev
	python-pydot
	linux-headers-generic
	linux-image-extra-virtual
	python-numpy
	swig
	python-pandas
	python-sklearn
	unzip
	wget
	pkg-config
	zip
	g++
	zlib1g-dev
	python-wheel
)

sudo apt-get -y update
sudo apt-get -y upgrade

echo "Installing apt-get packages..."
sudo apt-get install -y ${apt_packages[@]}
sudo pip install -U -y pip
sudo apt-get clean

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

sudo ./$anaconda -b -p /opt/anaconda

conda_path=/opt/anaconda/bin
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


# Install Tensorflow from source
cd ~

git clone --recursive https://github.com/tensorflow/tensorflow

cd tensorflow

export TF_CUDA_COMPUTE_CAPABILITIES="3.0"

./configure
bazel build -c opt --config=cuda tensorflow/tools/pip_package:build_pip_package
bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/pip
pip install --upgrade /tmp/pip/tensorflow-0.8.0-py2-none-any.whl

# Build image retrainer
# see: https://www.tensorflow.org/versions/master/how_tos/image_retraining/index.html
bazel build -c opt --copt=-mavx tensorflow/examples/image_retraining:retrain