#!/bin/bash

OS=linux
SINGULARITY_VERSION=3.8.3
DOCKER_BUILDX_VERSION=0.6.3
GO_VERSION=1.16.4

USER_DIR=/home/admin
DOCKERFILE_DIR=/singularity-docker-autoarch

print_usage() {
  printf "Script usage:

    -u: user directory path 
        -u /home/ubuntu  
    -s: Singularity version 
        -s 3.8.3  
    -d: Docker buildx version 
        -d 0.6.3
    -g: GO version 
        -g 1.16.4
    -o: Additional Architectures you wish to build in, must follow this format: 
        -o linux/arm64,linux/arm/v7 
    -a Dockerhub account, for pushing images to dockerhub
        -a dockerhubAccount1

"
}

# Optional arguments for the script
while getopts 'u:s:d:g:a:o:h' flag; do
  case "${flag}" in
    u) USER_DIR=$OPTARG ;;
    s) SINGULARITY_VERSION=$OPTARG ;;
    d) DOCKER_BUILDX_VERSION=$OPTARG ;;
    g) GO_VERSION=$OPTARG ;;
    o) ADDITIONAL_ARCH=$OPTARG ;;
    a) DOCKERHUB_ACCOUNT=$OPTARG ;;
    h) print_usage
       exit 1 ;;
    *) printf "\nInvalid option, use '-h' to see available options\n"
       exit 1 ;;
  esac
done

host_checks() {
    printf "User directory set to ${USER_DIR}\n"

    # Checks the cpu architecture
    if [ $(uname -p) = "aarch64" ] || [ $(uname -p) = "arm64" ]
    then
        ARCH="arm64"
        PLATFORM="${OS}/${ARCH},${ADDITIONAL_ARCH}"
    else
        ARCH="amd64"
        PLATFORM="${OS}/${ARCH},${ADDITIONAL_ARCH}"
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
        echo "Docker Buildx version: ${DOCKER_BUILDX_VERSION} downloaded"
    fi

    build_containers
}

build_containers() {
    printf "\nCreating docker container: singularity:v${SINGULARITY_VERSION}, using Docker Buildx on CPU architecture: ${PLATFORM}\n"

    if [ -z ${DOCKERHUB_ACCOUNT} ]
    then
        printf "No Dockerhub account provided, building locally\n"
        BUILD_NAME=singularity:${SINGULARITY_VERSION}
    else
        printf "Login to Dockerhub ID: ${DOCKERHUB_ACCOUNT}, "
        docker login -u ${DOCKERHUB_ACCOUNT}
        BUILD_NAME=${DOCKERHUB_ACCOUNT}/singularity:${SINGULARITY_VERSION}
        STORE_METHOD="--push"
        printf "Container builds will be pushed Dockerhub account ${DOCKERHUB_ACCOUNT}\n"
    fi

    # Creating the docker container for singularity using buildx
    cd ${USER_DIR}/${DOCKERFILE_DIR}
    docker buildx create \
        --driver-opt env.http_proxy=$http_proxy \
        --driver-opt env.https_proxy=$https_proxy \
        --driver-opt '"env.no_proxy='$no_proxy'"' \
        --driver-opt network=host \
        --platform ${PLATFORM} \
        --name singularity-builder

    docker buildx use singularity-builder

    docker buildx build \
        --build-arg http_proxy=$http_proxy \
        --build-arg https_proxy=$https_proxy \
        --build-arg SINGULARITY_VERSION=${SINGULARITY_VERSION} \
        --build-arg GO_VERSION=${GO_VERSION} \
        -t ${BUILD_NAME} \
        --platform ${PLATFORM} \
        . ${STORE_METHOD}
    
    docker rm buildx_buildkit_singularity-builder0 -f
    docker logout
}

if [ -d ${USER_DIR} ]
then
    host_checks
else
    printf "${USER_DIR} is not a valid directory, ensure that the correct home directory is set\n" 
    exit 1;
fi