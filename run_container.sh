#!/bin/bash

nvidia-docker run -it -p 8888:8888 -v ~:/vol mjm2tr/tensorflow:v1-aws-devel-gpu
