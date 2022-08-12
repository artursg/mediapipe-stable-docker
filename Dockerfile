FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

RUN echo "APT::Get::Assume-Yes "true";\nAPT::Get::force-yes "true";" >> /etc/apt/apt.conf.d/90forceyes
RUN apt-get update && apt-get install --no-install-recommends \
        build-essential \
        gcc-8 g++-8 \
        ca-certificates \
        curl \
        ffmpeg \
        git \
        wget \
        unzip \
        python3-dev \
        python3-opencv \
        python3-pip \
        libopencv-core-dev \
        libopencv-highgui-dev \
        libopencv-imgproc-dev \
        libopencv-video-dev \
        libopencv-calib3d-dev \
        libopencv-features2d-dev \
        software-properties-common \
        sudo \
        mesa-common-dev \
        libegl1-mesa-dev \
        libgles2-mesa-dev \
        mesa-utils && \
    add-apt-repository -y ppa:openjdk-r/ppa && \
    apt-get update && apt-get install -y openjdk-8-jdk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install bazel
ARG BAZEL_VERSION=5.2.0
RUN mkdir /bazel && \
    wget --no-check-certificate -O /bazel/installer.sh "https://github.com/bazelbuild/bazel/releases/download/5.2.0/bazel-${BAZEL_VERSION}-installer-linux-x86_64.sh" && \
    chmod +x /bazel/installer.sh && \
    /bazel/installer.sh && \
    rm -f /bazel/installer.sh

# Get Mediapipe
ARG MEDIAPIPE_VERSION=v0.8.10.2
RUN git clone https://github.com/google/mediapipe.git --branch ${MEDIAPIPE_VERSION} --depth 1

# Install opencv from source
RUN chmod +x /mediapipe/setup_opencv.sh && \
    /mediapipe/setup_opencv.sh

WORKDIR /mediapipe

# If we want the docker image to contain the pre-built object_detection_offline_demo binary, do the following
RUN bazel build --define MEDIAPIPE_DISABLE_GPU=1 mediapipe/examples/desktop/demo_run_graph_main