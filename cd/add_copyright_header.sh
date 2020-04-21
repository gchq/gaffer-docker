#!/bin/bash

# Copyright 2020 Crown Copyright
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

if [ $# -ne 2 ]; then
  echo "Usage: ./cd/add_copyright_header.sh <file glob> <header>"
  exit 1
fi

rootDirectory=$( cd $(dirname $(dirname $0)) > /dev/null 2>&1 && pwd )
fileGlob=$1
header=$2

for f in $(find "${rootDirectory}" -type f -name "${fileGlob}");
do
  if ! grep -q "Crown Copyright" ${f}; then
    echo ${f}

    if [[ ${f} =~ ^.*\.(xml|sh)$ ]]; then
      # Append after the first line for shell scripts and xml files
      firstLine=$(head -n 1 ${f})
      withoutFirstLine=$(sed -e "1s|^.*$||" ${f})
      echo -e "${firstLine}\n\n${header}\n${withoutFirstLine}" > ${f}
    else
      contents=$(cat ${f})
      echo -e "${header}\n\n${contents}" > ${f}
    fi
  fi
done
