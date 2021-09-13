#!/bin/bash

OS=linux
SINGULARITY_VERSION=3.8.3
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

echo "\nCreating docker container: singularity:v${SINGULARITY_VERSION}, using Docker Build on CPU architecture: ${PLATFORM} \n"
# Creating the docker container for singularity using buildx
docker build \
    --build-arg http_proxy=${HTTP_PROXY} \
    --build-arg https_proxy=${HTTPS_PROXY} \
    --build-arg SINGULARITY_VERSION=${SINGULARITY_VERSION} \
    --build-arg GO_VERSION=${GO_VERSION} \
    -t singularity:${SINGULARITY_VERSION} .