#!/bin/bash

nvidia-docker run -it -p 8888:8888 -v ~:/mnt mjm2tr/tensorflow:v1-aws-devel-gpu
