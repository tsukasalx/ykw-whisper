#!/bin/bash

# Check if docker is installed, if not, install the latest version
if ! [ -x "$(command -v docker)" ]; then
  echo "Error: docker is not installed." >&2
  echo "Installing docker..."
  curl -fsSL https://get.docker.com -o get-docker.sh
  sh get-docker.sh
fi

# Verify if installation is successful, if not, exit with error
if ! [ -x "$(command -v docker)" ]; then
  echo "Error: docker installation failed." >&2
  exit 1
else
  echo "docker installed successfully."
fi

# Check if docker-compose is installed, if not, install the latest version
if ! [ -x "$(command -v docker-compose)" ]; then
  echo "Error: docker-compose is not installed." >&2
  echo "Installing docker-compose..."
  curl -L https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m) \
       -o /usr/local/bin/docker-compose
  chmod +x /usr/local/bin/docker-compose
fi

# Verify if installation is successful, if not, exit with error
if ! [ -x "$(command -v docker-compose)" ]; then
  echo "Error: docker-compose installation failed." >&2
  exit 1
else
  echo "docker-compose installed successfully."
fi

# Check if ykw/whisper image exists, if not, build using docker-compose in ../docker/
ubuntu_version=$(lsb_release -sr)
export ubuntu_version
whisper_image_name=ykw/whisper$ubuntu_version

if ! docker images | grep -q $whisper_image_name; then
  echo "$whisper_image_name image not found. Building..."
  (cd $(dirname "$0")/../docker && docker-compose build --build-arg UBUNTU_VERSION=$ubuntu_version)
fi

# Verify if build is successful, if not, exit with error
if ! docker images | grep -q $whisper_image_name; then
  echo "Error: $whisper_image_name build failed." >&2
  exit 1
else
  echo "$whisper_image_name build successfully."
fi

output_dir="."
model_dir="$(dirname $0)/../models"
model="large"
output_format="srt"
is_output_ass=1
language="ja"
audios=()

options="-o ./output --model_dir ./model"

# Parse command-line options
while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      echo Args:
      echo "--proxy <http://your-http-proxy:prot>"
      echo
      echo "+--------------------------------------------------------------------------------------------------------------+"
      echo "| Available models and languages                                                                               |"
      echo "|--------------------------------------------------------------------------------------------------------------|"
      printf "| %-10s | %-15s | %-19s | %-19s | %-15s | %-15s |\n" "Size" "Parameters" "English-only model" "Multilingual model" "Required VRAM" "Relative speed"
      printf "| %-10s | %-15s | %-19s | %-19s | %-15s | %-15s |\n" "----------" "---------------" "-------------------" "-------------------" "---------------" "---------------"
      printf "| %-10s | %-15s | %-19s | %-19s | %-15s | %-15s |\n" "tiny" "39 M" "tiny.en" "tiny" "~1 GB" "~32x"
      printf "| %-10s | %-15s | %-19s | %-19s | %-15s | %-15s |\n" "base" "74 M" "base.en" "base" "~1 GB" "~16x"
      printf "| %-10s | %-15s | %-19s | %-19s | %-15s | %-15s |\n" "small" "244 M" "small.en" "small" "~2 GB" "~6x"
      printf "| %-10s | %-15s | %-19s | %-19s | %-15s | %-15s |\n" "medium" "769 M" "medium.en" "medium" "~5 GB" "~2x"
      printf "| %-10s | %-15s | %-19s | %-19s | %-15s | %-15s |\n" "large" "1550 M" "N/A" "large" "~10 GB" "1x"
      echo "+--------------------------------------------------------------------------------------------------------------+"

      docker run --rm $whisper_image_name whisper --help
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
    --proxy)
      export http_proxy="$2"
      export https_proxy="$2"
      shift 2
      ;;
    -*)
      options="$options $1 $2"
      shift 2
      ;;
    *)
      audios+=("$1")
      shift
      ;;
  esac
done

options="$options --model $model"
options="$options --output_format $output_format"
options="$options --language $language"

# Process audio files
if [ "${output_dir:0:1}" != "/" ]; then
  output_dir="$PWD/$output_dir"
fi
output_dir=$(realpath "$output_dir")
tmp_dir=/tmp/$(uuidgen)
if [ "${model_dir:0:1}" != "/" ]; then
  model_dir="$PWD/$model_dir"
fi
model_dir=$(realpath "$model_dir")

total_elapsed_time=0
for audio in "${audios[@]}"; do

  start_time=$(date +%s)

  # Make sure we use the absolutely path
  if [ "${audio:0:1}" != "/" ]; then
    host_audio="$PWD/$audio"
    host_audio=$(realpath "$host_audio")
  else
    host_audio="$audio"
  fi
  docker_audio=/app/input/$(basename "$audio")

  # Process the audio in a new container
  docker run --gpus all \
             --rm \
             -v "$host_audio:$docker_audio:ro" \
             -v "$tmp_dir:/app/output" \
             -v "$model_dir:/app/model:ro" \
             $whisper_image_name whisper $options "$docker_audio"
                  
  if [[ $? -ne 0 ]]; then
    exit 1
  fi

  # Generate ass file if need
  if [[ $is_output_ass -eq 1 ]]; then
    file_name=$(basename "$host_audio")
    file_name_without_ext=${file_name%.*}
    docker run --rm \
               -v "$tmp_dir:/app/output" \
               $whisper_image_name ffmpeg -y -i \
               "/app/output/$file_name_without_ext.srt" \
               "/app/output/$file_name_without_ext.ass" >/dev/null 2>&1
    
    if [[ $? -ne 0 ]]; then
      exit 1
    fi
  fi

  elapsed_time=$(($(date +%s) - start_time))
  echo "$audio elapsed time: $(date -d@${elapsed_time} -u +%H:%M:%S)"
  total_elapsed_time=$((total_elapsed_time + elapsed_time))
done

cp -r $tmp_dir/* $output_dir
for audio in "${audios[@]}"; do
    if [[ $output_format == "srt" ]]; then
      rm "$output_dir/$file_name_without_ext.srt"
    fi
done

echo "Total elapsed time: $(date -d@${total_elapsed_time} -u +%H:%M:%S)"

echo "All steps completed successfully."
