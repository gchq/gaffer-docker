#!/bin/bash

# Copyright 2020-2024 Crown Copyright
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

# -a: Always export variables to subsequent commands.
# Required for variables from sourced env file to automatically be visible to docker compose.
set -e -a

ROOT_DIR="$(readlink -f "$(dirname "$(dirname "${0}")")")"

pushd "${ROOT_DIR}" || exit 1

# The following env file will be sourced to set:
# HADOOP_VERSION
# GAFFER_VERSION
# ACCUMULO_VERSION
if [[ -f "${1}" ]]; then
    source "${1}"
else
    echo "Error - Environment file not set"
    exit 1
fi

# Builds the Gaffer and Accumulo related images:
docker compose --project-directory ./docker/accumulo/ -f ./docker/accumulo/docker-compose.yaml build
docker compose --project-directory ./docker/gaffer-road-traffic-loader/ -f ./docker/gaffer-road-traffic-loader/docker-compose.yaml build

popd || exit 1
