#!/usr/bin/env bash


#
source ~/.bashrc

conda install pip -y


# Install Tensorflow from source
cd ~

git clone --recursive https://github.com/tensorflow/tensorflow

cd tensorflow

export TF_CUDA_COMPUTE_CAPABILITIES="3.0"

./configure && \
	bazel build -c opt --config=cuda //tensorflow/cc:tutorials_example_trainer && \
	bazel build -c opt --config=cuda tensorflow/tools/pip_package:build_pip_package && \
	bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/pip && \
	pip install --upgrade --ignore-installed /tmp/pip/tensorflow-0.8.0-py2-none-any.whl # Using --ignore-installed due to similar issue to this: https://github.com/ContinuumIO/anaconda-issues/issues/542

# # Build image retrainer
# # see: https://www.tensorflow.org/versions/master/how_tos/image_retraining/index.html
bazel build -c opt --copt=-mavx tensorflow/examples/image_retraining:retrain

## Configure Jupyter (taken from http://eatcodeplay.com/installing-gpu-enabled-tensorflow-with-python-3-4-in-ec2/)

# # ec2
# jupyter notebook --generate-config

# key=$(python -c "from notebook.auth import passwd; print(passwd())")
# # When prompted you'll need to specify a password

# # Create certs
# cd ~
# mkdir certs
# cd certs
# certdir=$(pwd)
# openssl req -x509 -nodes -days 365 -newkey rsa:1024 -keyout mycert.key -out mycert.pem
# # You'll be prompted to enter values for the cert,
# # but it doesn't much matter, you can just leave them all blank.

# cd ~
# sed -i "1 a\
# c = get_config()\\
# c.NotebookApp.certfile = u'$certdir/mycert.pem'\\
# c.NotebookApp.ip = '*'\\
# c.NotebookApp.open_browser = False\\
# c.NotebookApp.password = u'$key'\\
# c.NotebookApp.port = 8888" .jupyter/jupyter_notebook_config.py

# # Start Jupyter
# mkdir -p ~/notebooks
# cd ~/notebooks
# jupyter notebook --certfile=~/certs/mycert.pem --keyfile ~/certs/mycert.key

# # open a browser to https://[my_ec2_ip]:8888   IMPORT TO USE HTTPS