FROM nvidia/cuda:12.1.0-base-ubuntu20.04

WORKDIR /app

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update
RUN apt install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confold" keyboard-configuration
RUN apt install -y git
RUN apt install -y ffmpeg
RUN apt install -y curl
RUN apt install -y python3.9
RUN apt install -y python3.9-distutils
RUN curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
RUN python3 get-pip.py

RUN pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu117
RUN pip install git+https://github.com/openai/whisper.git 
