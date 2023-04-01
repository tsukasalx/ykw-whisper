#!/bin/bash

# Check if docker is installed, if not, install the latest version
if ! [ -x "$(command -v docker)" ]; then
  echo 'Error: docker is not installed.' >&2
  echo 'Installing docker...'
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
fi

# Verify if installation is successful, if not, exit with error
if ! [ -x "$(command -v docker)" ]; then
  echo 'Error: docker installation failed.' >&2
  exit 1
else
  echo 'docker installed successfully.'
fi

# Check if docker-compose is installed, if not, install the latest version
if ! [ -x "$(command -v docker-compose)" ]; then
  echo 'Error: docker-compose is not installed.' >&2
  echo 'Installing docker-compose...'
  curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) \
       -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
fi

# Verify if installation is successful, if not, exit with error
if ! [ -x "$(command -v docker-compose)" ]; then
  echo 'Error: docker-compose installation failed.' >&2
  exit 1
else
  echo 'docker-compose installed successfully.'
fi

# Check if ykw/whisper image exists, if not, build using docker-compose in ../docker/
if ! docker images | grep -q ykw/whisper; then
  echo 'ykw/whisper image not found. Building...'
  (cd $(dirname "$0")/../docker && docker-compose build)
fi

# Verify if build is successful, if not, exit with error
if ! docker images | grep -q ykw/whisper; then
  echo 'Error: ykw/whisper build failed.' >&2
  exit 1
else
  echo 'ykw/whisper build successfully.'
fi

output_dir="."
model_dir="$(dirname $0)/../models"
model="large-v2"
output_format="srt"
is_output_ass=1
language="ja"
audios=()

options="-o ./output --model_dir ./model"

# Parse command-line options
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      docker run --rm ykw/whisper whisper --help
      exit 0
      ;;
    -o|--output_dir)
      output_dir="$2"
      shift 2
      ;;
    --model_dir)
      model_dir="$2"
      shift 2
      ;;
    --model)
      model="$2"
      shift 2
      ;;
    --output_format)
      if [[ $2 == "ass" ]]; then
        output_format="$output_format"
      elif [[ $2 == "all" ]]; then
        output_format="$2"
      else
        output_format="$2"
        is_output_ass=0
      fi
      shift 2
      ;;
    --language)
      language="$2"
      shift 2
      ;;
    -*)
      options="$options $1 $2"
      shift 2
      ;;
    *)
      audios+="$1 "
      shift
      ;;
  esac
done

options="$options --model $model"
options="$options --output_format $output_format"
options="$options --language $language"

# Process audio files
for audio in $audios; do
  # Make sure we use the absolutely path
  if [ "${audio:0:1}" != "/" ]; then
    audio="$PWD/$audio"
  fi
  if [ "${output_dir:0:1}" != "/" ]; then
    output_dir="$PWD/$output_dir"
  fi
  if [ "${model_dir:0:1}" != "/" ]; then
    model_dir="$PWD/$model_dir"
  fi
  # Process the audio in a new container
  docker run --rm \
              -v $audio:/app/input/$(basename $audio) \
              -v $output_dir:/app/output \
              -v $model_dir:/app/model \
              ykw/whisper whisper $options /app/input/$(basename $audio)

  if [[ $? -ne 0 ]]; then
    exit 1
  fi

  # Generate ass file if need
  if [[ $is_output_ass -eq 1 ]]; then
    file_name=$(basename $audio)
    file_name_without_ext=${file_name%.*}
    ffmpeg -y -i $output_dir/$file_name_without_ext.srt $output_dir/$file_name_without_ext.ass >/dev/null 2>&1

    if [[ $? -ne 0 ]]; then
      exit 1
    fi

    if [[ $output_format == "srt" ]]; then
      rm $output_dir/$file_name_without_ext.srt
    fi
  fi
done

echo "All steps completed successfully."
