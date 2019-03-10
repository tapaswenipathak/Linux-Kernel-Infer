FROM ubuntu:16.04

MAINTAINER Tapasweni Pathak

## Install packages
RUN apt update
RUN echo | apt-get install  --no-install-recommends \
    autoconf \
    automake \
    build-essential \
    git \
    libgmp-dev \
    libmpc-dev \
    libmpfr-dev \
    libsqlite3-dev \
    m4 \
    opam \
    openjdk-8-jdk \
    unzip \
    zlib1g-dev \
    rsync \
    pkg-config \
    libncurses-dev \
    python \
    aspcud

# Download the latest Infer release
RUN INFER_VERSION=v0.15.0; \
    cd /opt && \
    curl -sL \
      https://github.com/facebook/infer/releases/download/${INFER_VERSION}/infer-linux64-${INFER_VERSION}.tar.xz | \
    tar xJ && \
    rm -f /infer && \
    ln -s ${PWD}/infer-linux64-$INFER_VERSION /infer


# Install Infer
ENV INFER_HOME /infer/infer
ENV PATH ${INFER_HOME}/bin:${PATH}
RUN ln -s /infer/bin/infer /usr/local/bin/infer
