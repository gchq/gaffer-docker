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

# Gets project root directory by calling two nested "dirname" commands on the this file
getRootDirectory() {
    echo "$( cd $(dirname $(dirname $0)) > /dev/null 2>&1 && pwd )"
}

# Retrieve versions from files
ROOT_DIR="$(getRootDirectory)"
APP_VERSION="$(cat ${ROOT_DIR}/app_version)"

# This set's the values for:
# HADOOP_VERSION
# GAFFER_VERSION
# ACCUMULO_VERSION
source "${ROOT_DIR}"/docker/gaffer/.env

# Build index.yaml file
git checkout gaffer-docker/issue#32
cd ./kubernetes/dist/
helm repo index . --url https://github.com/gchq/gaffer-docker/releases/tag/v"${APP_VERSION}"
git commit -a -m "Chart directories pacakaged and index.yaml file built"
#git push origin master