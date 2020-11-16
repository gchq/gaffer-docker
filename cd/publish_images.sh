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

# Script for publishing to DockerHub
# Requires the following environment variables to be set:
# APP_VERSION - the release name
# DOCKER_USERNAME - the dockerhub username
# DOCKER_PASSWORD - the docker password

# Gets project root directory by calling two nested "dirname" commands on the this file
getRootDirectory() {
    echo "$( cd $(dirname $(dirname $0)) > /dev/null 2>&1 && pwd )"
}

# Pushes Tags to Dockerhub
pushTags() {
    name=$1
    version=$2
    app_version=$3
    tags="$(echo ${version} | sed -e "s|\(.*\)\.\(.*\)\..*|${name}:${version}_build.${app_version} ${name}:${version} ${name}:\1.\2 ${name}:\1 ${name}:latest|")"
    IFS=' '
    read -a tagArray <<< "${tags}"
    for tag in "${tagArray[@]}"; do
        docker tag "${name}:${version}" "${tag}"
        docker push "${tag}"
    done
}

ROOT_DIR="$(getRootDirectory)"

# This sets the values for:
# HADOOP_VERSION
# GAFFER_VERSION
# ACCUMULO_VERSION
source "${ROOT_DIR}"/docker/gaffer/.env

# Log in to Dockerhub
docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}"

# Push images to Dockerhub
pushTags gchq/hdfs "${HADOOP_VERSION}" "${APP_VERSION}"
pushTags gchq/accumulo "${ACCUMULO_VERSION}" "${APP_VERSION}"
pushTags gchq/gaffer "${GAFFER_VERSION}" "${APP_VERSION}"
pushTags gchq/gaffer-rest "${GAFFER_VERSION}" "${APP_VERSION}"
pushTags gchq/gaffer-road-traffic-loader "${GAFFER_VERSION}" "${APP_VERSION}"
pushTags gchq/gaffer-operation-runner "${GAFFER_VERSION}" "${APP_VERSION}"
