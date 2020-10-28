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

buildImages() {
    docker-compose --project-directory ../../docker/accumulo/ -f ../../docker/accumulo/docker-compose.yaml build
    docker-compose --project-directory ../../docker/gaffer-operation-runner/ -f ../../docker/gaffer-operation-runner/docker-compose.yaml build
}

# Lint Helm Charts
for chart in ./kubernetes/*; do
    if [ -f "${chart}/Chart.yaml" ]; then
        flags=''
        [ ! -f "${chart}/values-insecure.yaml" ] || flags="-f ${chart}/values-insecure.yaml"

        helm dependency update ${chart}
        helm lint ${flags} ${chart}
        helm template test ${flags} ${chart} >/dev/null
    fi
done

cd kubernetes/gaffer-road-traffic

if [ ${TRAVIS_PULL_REQUEST} == 'false' ]; then
    if [ "${TRAVIS_BRANCH}" == "master" ]; then
        # Build images so they can be pushed later
        buildImages
    fi
    exit 0
fi

# Create a cluster
kind create cluster --quiet

buildImages

# Deploy Images to Kind
kind load docker-image gchq/hdfs:3.2.1
kind load docker-image gchq/gaffer:1.13.4
kind load docker-image gchq/gaffer-rest:1.13.4
kind load docker-image gchq/gaffer-road-traffic-loader:1.13.4
kind load docker-image gchq/gaffer-operation-runner:1.13.4

# Deploy containers onto Kind
# Travis needs this setting to avoid reverse dns lookup errors
echo "Starting helm install"
helm install gaffer . -f ./values-insecure.yaml --set gaffer.hdfs.config.hdfsSite."dfs\.namenode\.datanode\.registration\.ip-hostname-check"=false
