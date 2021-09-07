ARG BASE_IMAGE

FROM ${BASE_IMAGE}

ARG OS
ARG BASE_IMAGE
ARG PLATFORM
ARG SINGULARITY_VERSION
ARG GO_VERSION

RUN echo "Running on ${OS}/${BASE_IMAGE}, building Singularity v${SINGULARITY_VERSION} for ${PLATFORM}"

RUN export DEBIAN_FRONTEND=noninteractive && \
    apt-get update && apt-get install -y \
    build-essential \
    libssl-dev \
    uuid-dev \
    libgpgme11-dev \
    squashfs-tools \
    libseccomp-dev \
    wget \
    pkg-config \
    git \
    cryptsetup

RUN export ARCH=$(echo ${PLATFORM} | cut -f2 -d'/') && \
    export GO_ARCHIVE=go${GO_VERSION}.${OS}-${ARCH}.tar.gz && \
    wget https://dl.google.com/go/${GO_ARCHIVE} && \
    tar -C /usr/local -xzvf ${GO_ARCHIVE} && \
    rm ${GO_ARCHIVE}

RUN echo 'export PATH=/usr/local/go/bin:${PATH}' >> ~/.bashrc

RUN export SINGULARITY_ARCHIVE=singularity-ce-${SINGULARITY_VERSION}.tar.gz && \
    wget https://github.com/sylabs/singularity/releases/download/v${SINGULARITY_VERSION}/${SINGULARITY_ARCHIVE} && \
    tar -xzf ${SINGULARITY_ARCHIVE} && \
    rm ${SINGULARITY_ARCHIVE}

RUN export SINGULARITY_DIR=singularity-ce-${SINGULARITY_VERSION} && \
    . ~/.bashrc && \
    cd ${SINGULARITY_DIR} && \
    ./mconfig && \
    make -C builddir && \
    make -C builddir install && \
    cd .. && \
    rm -rf ${SINGULARITY_DIR}

ENTRYPOINT ["/usr/local/bin/singularity"]