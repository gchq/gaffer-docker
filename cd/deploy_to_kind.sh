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

set -x

kind create cluster --quiet --config ./cd/kind.yaml --image kindest/node:v1.24.4

# This sets the values for:
# HADOOP_VERSION
# GAFFER_VERSION
# SPARK_VERSION
# KUBECTL_VERSION
if [[ -f "${1}" ]]; then
    source "${1}"
else
    echo "Error - Environment file not set"
    exit 1
fi
# JHUB_OPTIONS_SERVER_VERSION
source ./docker/gaffer-jhub-options-server/get-version.sh

# Deploy Images to Kind
kind load docker-image gchq/hdfs:${HADOOP_VERSION}
kind load docker-image gchq/gaffer:${GAFFER_VERSION}-accumulo-${ACCUMULO_VERSION}
kind load docker-image gchq/gaffer-rest:${GAFFER_VERSION}-accumulo-${ACCUMULO_VERSION}
kind load docker-image gchq/gaffer-road-traffic-loader:${GAFFER_VERSION}
kind load docker-image gchq/gaffer-jhub-options-server:${JHUB_OPTIONS_SERVER_VERSION}


# Deploy containers onto Kind
# Hostname check is disabled for CI
echo "Starting helm install for gaffer-road-traffic"
pushd ./kubernetes/gaffer-road-traffic
if ! helm install gaffer . \
    --timeout=15m \
    --debug \
    --set gaffer.accumulo.hdfs.config.hdfsSite."dfs\.namenode\.datanode\.registration\.ip-hostname-check"=false
then
    kubectl logs "$(kubectl get pods -A | grep -o gaffer-gaffer-road-traffic-data-loader-[a-z0-9]*)"
fi
popd

echo "Starting helm install for gaffer-jhub"
pushd ./kubernetes/gaffer-jhub
helm install jhub . -f ./values-insecure.yaml
popd
