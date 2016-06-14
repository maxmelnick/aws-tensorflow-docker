#!/usr/bin/env bash






# Install Tensorflow from source
# cd ~

# git clone --recursive https://github.com/tensorflow/tensorflow

# cd tensorflow

# export TF_CUDA_COMPUTE_CAPABILITIES="3.0"

# ./configure && \
# 	bazel build -c opt --config=cuda tensorflow/tools/pip_package:build_pip_package && \
# 	bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/pip && \
# 	pip install --upgrade /tmp/pip/tensorflow-0.8.0-py2-none-any.whl

# # Build image retrainer
# # see: https://www.tensorflow.org/versions/master/how_tos/image_retraining/index.html
# bazel build -c opt --copt=-mavx tensorflow/examples/image_retraining:retrain