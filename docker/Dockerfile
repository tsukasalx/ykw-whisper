ARG UBUNTU_VERSION

FROM nvidia/cuda:12.1.0-base-ubuntu22.04

WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y git ffmpeg python3-pip && \
    rm -rf /var/lib/apt/lists/*

RUN pip install git+https://github.com/openai/whisper.git && \
    pip install pysubs2 && \
    pip install flake8

COPY src /app/src
