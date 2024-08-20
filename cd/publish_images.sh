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

# Script for publishing to DockerHub
# Requires the following environment variables to be set:
# DOCKER_USERNAME - the dockerhub username
# DOCKER_PASSWORD - the dockerhub password
# GHCR_USERNAME - the ghcr.io username
# GHCR_PASSWORD - the ghcr.io password/token

# Gets project root directory by calling two nested "dirname" commands on the this file
getRootDirectory() {
    echo "$( cd $(dirname $(dirname $0)) > /dev/null 2>&1 && pwd )"
}

# Generate tags based on version
# Default is to tag version with full, major.minor, major, latest
getTags() {
    if [[ $tagsetting = "nolatest" ]];
    then
      tags="$(echo ${version} | sed -E "s|([0-9]+)\.([0-9]+).*|${name}:${version} ${name}:\1.\2 ${name}:\1|")"
    elif [[ $tagsetting = "nomajor" ]];
    then
      tags="$(echo ${version} | sed -E "s|([0-9]+)\.([0-9]+).*|${name}:${version} ${name}:\1.\2|")"
    else
      tags="$(echo ${version} | sed -E "s|([0-9]+)\.([0-9]+).*|${name}:${version} ${name}:\1.\2 ${name}:\1 ${name}:latest|")"
    fi
}

# Generate tags based on Gaffer version and Dependency version
# Default is to tag version with full, major.minor.patch, major.minor, major, latest
getTagsWithDependency() {
    dependencyname=$1
    if [[ $tagsetting = "onlyfull" ]];
    then
      tags="${name}:${version}"
    else
      tags="$(echo ${version} | sed -E "s|([0-9]+)\.([0-9]+)\.([0-9]+)-${dependencyname}-([0-9.]*)|${name}:${version} ${name}:\1.\2.\3 ${name}:\1.\2 ${name}:\1 ${name}:latest|")"
    fi
}

# Tags and pushes containers to repositories
pushContainer() {
    name=$1
    version=$2
    tagsetting=$3
    regex='[0-9]+\.[0-9]+\.[0-9]+-([[:alpha:]]+)-[0-9.]*'
    if [[ $version =~ $regex ]]; then
      getTagsWithDependency ${BASH_REMATCH[1]}
    else
      getTags
    fi
    IFS=' '
    read -a tagArray <<< "${tags}"

    # Upload to Docker Hub Container Image Library
    for tag in "${tagArray[@]}"; do
        docker tag "${name}:${version}" "${tag}"
        echo "Uploading ${tag} to docker.io"
        docker push --quiet "${tag}"
    done
    # Upload to GitHub Container Repository
    for tag in "${tagArray[@]}"; do
        docker tag "${name}:${version}" ghcr.io/"${tag}"
        echo "Uploading ${tag} to ghcr.io"
        docker push --quiet ghcr.io/"${tag}"
    done
}

ROOT_DIR="$(getRootDirectory)"

# This sets the values for:
# HADOOP_VERSION
# GAFFER_VERSION
# ACCUMULO_VERSION
# SPARK_VERSION
source "${ROOT_DIR}"/docker/accumulo2.env
# JHUB_OPTIONS_SERVER_VERSION
source "${ROOT_DIR}"/docker/gaffer-jhub-options-server/get-version.sh

# Log in to Docker Hub Container Image Library
docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}"
# Log in to GitHub Container Repository
docker login ghcr.io -u "${GHCR_USERNAME}" -p "${GHCR_PASSWORD}"

# Push to Container Repositories
pushContainer gchq/hdfs "${HADOOP_VERSION}"
pushContainer gchq/accumulo "${ACCUMULO_VERSION}"
pushContainer gchq/gaffer "${GAFFER_VERSION}-accumulo-${ACCUMULO_VERSION}"
pushContainer gchq/gaffer-rest "${GAFFER_VERSION}-accumulo-${ACCUMULO_VERSION}"
pushContainer gchq/gaffer-road-traffic-loader "${GAFFER_VERSION}"
pushContainer gchq/gaffer-pyspark-notebook "${GAFFER_VERSION}"
pushContainer gchq/gaffer-jhub-options-server "${JHUB_OPTIONS_SERVER_VERSION}"
pushContainer gchq/spark-py "${SPARK_VERSION}"

# Push legacy versions to Container Repositories
source "${ROOT_DIR}"/docker/accumulo1.env
pushContainer gchq/hdfs "${HADOOP_VERSION}" nomajor
pushContainer gchq/accumulo "${ACCUMULO_VERSION}" nolatest
pushContainer gchq/gaffer "${GAFFER_VERSION}-accumulo-${ACCUMULO_VERSION}" onlyfull
pushContainer gchq/gaffer-rest "${GAFFER_VERSION}-accumulo-${ACCUMULO_VERSION}" onlyfull
