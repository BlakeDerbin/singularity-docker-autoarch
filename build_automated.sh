#!/bin/bash

OS=linux
SINGULARITY_VERSION=3.8.3
DOCKER_BUILDX_VERSION=0.6.3

HTTP_PROXY=http://10.0.214.52:9898
HTTPS_PROXY=http://10.0.214.52:9898

USER_DIR=/home/admin
DOCKERFILE_DIR=/singularity-docker-autoarch

if [ $(uname -p) = "aarch64" ] || [ $(uname -p) = "arm64" ]
then
    ARCH="arm64"
    PLATFORM="${OS}/${ARCH}"
else
    ARCH="amd64"
    PLATFORM="${OS}/${ARCH}"
fi

if [ ! -d ${USER_DIR}/.docker ]
then
    mkdir ${USER_DIR}/.docker
    cd ${USER_DIR}/.docker
    mkdir cli-plugins
else
    cd ${USER_DIR}/.docker
    if [ ! -d cli-plugins ] ; then mkdir cli-plugins ; fi
fi

DOCKER_BUILDX_FILE=buildx-v${DOCKER_BUILDX_VERSION}.${OS}-${ARCH}
cd ${USER_DIR}/.docker/cli-plugins

if [ ! -f ${DOCKER_BUILDX_FILE}* ]
then
    wget "https://github.com/docker/buildx/releases/download/v${DOCKER_BUILDX_VERSION}/${DOCKER_BUILDX_FILE}"
    chmod a+x ${USER_DIR}/.docker/cli-plugins/${DOCKER_BUILDX_FILE}
    docker buildx install
    echo "Docker buildx version: ${DOCKER_BUILDX_VERSION} installed"
fi

echo "\nCreating docker container for singularity:v${SINGULARITY_VERSION} using Docker Buildx on CPU architecture:${PLATFORM} \n"

cd ${USER_DIR}${DOCKERFILE_DIR}
docker buildx create --use --name builder
docker buildx build \
    --build-arg http_proxy=${HTTP_PROXY} \
    --build-arg https_proxy=${HTTPS_PROXY} \
    -t singularity:${SINGULARITY_VERSION} \
    --platform ${PLATFORM} .
#docker buildx rm builder