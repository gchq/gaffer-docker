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

set -e

root_directory="$( cd $(dirname $(dirname $0)) > /dev/null 2>&1 && pwd )"
cd $root_directory

# The following command sets:
# HADOOP_VERSION
# GAFFER_VERSION
# GAFFER_TOOLS_VERSION
# ACCUMULO_VERSION
# SPARK_VERSION
source ./docker/gaffer-pyspark-notebook/.env

docker-compose --project-directory ./docker/accumulo/ -f ./docker/accumulo/docker-compose.yaml build
docker-compose --project-directory ./docker/gaffer-ui/ -f ./docker/gaffer-ui/docker-compose.yaml build
docker-compose --project-directory ./docker/gaffer-road-traffic-loader/ -f ./docker/gaffer-road-traffic-loader/docker-compose.yaml build
docker-compose --project-directory ./docker/gaffer-pyspark-notebook/ -f ./docker/gaffer-pyspark-notebook/docker-compose.yaml build notebook
docker-compose --project-directory ./docker/spark-py/ -f ./docker/spark-py/docker-compose.yaml build

# Set $JHUB_OPTIONS_SERVER_VERSION
source ./docker/gaffer-jhub-options-server/get-version.sh
docker-compose --project-directory ./docker/gaffer-jhub-options-server/ -f ./docker/gaffer-jhub-options-server/docker-compose.yaml build
