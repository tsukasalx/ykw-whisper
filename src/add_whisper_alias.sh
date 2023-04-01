#!/bin/bash

function print_help {
  echo "Usage: $(basename $0) [-h] <alias_name>"
}

if [[ $1 == "-h" ]]; then
  print_help
  exit 0
fi
alias_name=$1
if [[ -z $alias_name ]]; then
  alias_name="ykw-whisper"
fi

if [[ ${0:0:1} != "/" ]]; then
  script_dir=$(dirname $PWD/$0)
else
  script_dir=$(dirname $0)
fi
script_dir=$(realpath $script_dir)

$(dirname $0)/shell_utils/src/add_alias.sh -y $alias_name $script_dir/run-whisper.sh
