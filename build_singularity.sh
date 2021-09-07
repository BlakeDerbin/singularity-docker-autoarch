#!/bin/bash
export OS=linux
export BASE_IMAGE=ubuntu:20.04
export GO_VERSION=1.16.4
export SINGULARITY_VERSION=3.8.2
export CPU_ARCH=$(uname -m)

if [ $CPU_ARCH = "aarch64" ] 
then
    export PLATFORM=${OS}/arm64
    CONTAINER_NAME=singularity_arm
else
    export PLATFORM=${OS}/amd64
    CONTAINER_NAME=singularity
fi

docker build \
    --build-arg OS \
    --build-arg BASE_IMAGE \
    --build-arg GO_VERSION \
    --build-arg SINGULARITY_VERSION \
    --build-arg PLATFORM \
    --no-cache \
    -t $CONTAINER_NAME:$SINGULARITY_VERSION .