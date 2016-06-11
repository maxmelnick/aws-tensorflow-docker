FROM gcr.io/tensorflow/tensorflow:latest-devel-gpu

WORKDIR /tensorflow

# recompile Tensorflow from source with TF_CUDA_COMPUTE_CAPABILITIES set to 3.0 for AWS
# GPU instance compatability
ENV TF_CUDA_COMPUTE_CAPABILITIES 3.0

RUN ./configure && \
    bazel build -c opt --config=cuda tensorflow/tools/pip_package:build_pip_package && \
    bazel-bin/tensorflow/tools/pip_package/build_pip_package /tmp/pip && \
    pip install --upgrade /tmp/pip/tensorflow-*.whl


# Build image retrainer
# see: https://www.tensorflow.org/versions/master/how_tos/image_retraining/index.html
RUN bazel build -c opt --copt=-mavx tensorflow/examples/image_retraining:retrain

RUN ["/bin/bash"]
