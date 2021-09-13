#!/bin/bash

OS=linux
SINGULARITY_VERSION=3.8.3
DOCKER_BUILDX_VERSION=0.6.3
GO_VERSION=1.16.4

# Set your proxies here if needed
HTTP_PROXY=$http_proxy
HTTPS_PROXY=$https_proxy

USER_DIR=/home/ubuntu
DOCKERFILE_DIR=/singularity-docker-autoarch

print_usage() {
  printf " Usage:
        -u: user directory path i.e. /home/ubuntu  
        -s: Singularity version i.e. 3.8.3  
        -d: Docker buildx version i.e. 0.6.3
        -g: GO version i.e. 1.16.4

"
}

# Optional arguments for the script
while getopts 'u:s:d:g:' flag; do
  case "${flag}" in
    u) USER_DIR=$OPTARG ;;
    s) SINGULARITY_VERSION=$OPTARG ;;
    d) DOCKER_BUILDX_VERSION=$OPTARG ;;
    g) GO_VERSION=$OPTARG ;;
    *) print_usage
       exit 1 ;;
  esac
done

echo "User directory set to ${USER_DIR}"

# Checks the cpu architecture
if [ $(uname -p) = "aarch64" ] || [ $(uname -p) = "arm64" ]
then
    ARCH="arm64"
    PLATFORM="${OS}/${ARCH}"
else
    ARCH="amd64"
    PLATFORM="${OS}/${ARCH}"
fi

# Checks if the local user directory container the .docker directory
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

# Checks if the docker buildx file doesn't exist
if [ ! -f ${DOCKER_BUILDX_FILE}* ]
then
    wget "https://github.com/docker/buildx/releases/download/v${DOCKER_BUILDX_VERSION}/${DOCKER_BUILDX_FILE}"
    chmod a+x ${USER_DIR}/.docker/cli-plugins/${DOCKER_BUILDX_FILE}
    docker buildx install
    echo "Docker buildx version: ${DOCKER_BUILDX_VERSION} installed"
fi

echo "\nCreating docker container: singularity:v${SINGULARITY_VERSION}, using Docker Buildx on CPU architecture: ${PLATFORM} \n"

# Creating the docker container for singularity using buildx
docker buildx create \ 
    --name singularity-builder \ 
    --driver-opt network=host

docker buildx use singularity-builder

docker buildx build \
    --build-arg http_proxy=${HTTP_PROXY} \
    --build-arg https_proxy=${HTTPS_PROXY} \
    --build-arg SINGULARITY_VERSION=${SINGULARITY_VERSION} \
    --build-arg GO_VERSION=${GO_VERSION} \
    -t singularity:${SINGULARITY_VERSION} \
    --platform ${PLATFORM} . --load