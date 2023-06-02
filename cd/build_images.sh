#!/bin/bash

# Copyright 2020-2023 Crown Copyright
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

root_directory="$( cd $(dirname $(dirname $0)) > /dev/null 2>&1 && pwd )"
cd $root_directory

if [ ! -z "$1" ]; then
	ENV_FILE=$1
else
	echo "Error - Environment file not set"; exit 1;
fi

# The following command sets:
# HADOOP_VERSION
# GAFFER_VERSION
# GAFFERPY_VERSION
# ACCUMULO_VERSION
# SPARK_VERSION
source "${ENV_FILE}"

# Builds all of the Gaffer and Accumulo related images:
docker compose --project-directory ./docker/accumulo/ -f ./docker/accumulo/docker-compose.yaml build
docker compose --project-directory ./docker/gaffer-road-traffic-loader/ -f ./docker/gaffer-road-traffic-loader/docker-compose.yaml build
# Builds all of the notebook related images:
docker compose --project-directory ./docker/gaffer-pyspark-notebook/ -f ./docker/gaffer-pyspark-notebook/docker-compose.yaml build notebook
docker compose --project-directory ./docker/spark-py/ -f ./docker/spark-py/docker-compose.yaml build

# Set $JHUB_OPTIONS_SERVER_VERSION
source ./docker/gaffer-jhub-options-server/get-version.sh
# Builds the jhub options server:
docker compose --project-directory ./docker/gaffer-jhub-options-server/ -f ./docker/gaffer-jhub-options-server/docker-compose.yaml build
