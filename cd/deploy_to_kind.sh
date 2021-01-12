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

kind create cluster --quiet --config ./cd/kind.yaml

# This sets the values for:
# HADOOP_VERSION
# GAFFER_VERSION
# SPARK_VERSION
source ./docker/gaffer-pyspark-notebook/.env
# JHUB_OPTIONS_SERVER_VERSION
source ./docker/gaffer-jhub-options-server/get-version.sh

# Deploy Images to Kind
kind load docker-image gchq/hdfs:${HADOOP_VERSION}
kind load docker-image gchq/gaffer:${GAFFER_VERSION}
kind load docker-image gchq/gaffer-rest:${GAFFER_VERSION}
kind load docker-image gchq/gaffer-road-traffic-loader:${GAFFER_VERSION}
kind load docker-image gchq/gaffer-operation-runner:${GAFFER_VERSION}
kind load docker-image gchq/gaffer-pyspark-notebook:${GAFFER_VERSION}
kind load docker-image gchq/gaffer-jhub-options-server:${JHUB_OPTIONS_SERVER_VERSION}
kind load docker-image gchq/spark-py:${SPARK_VERSION}

# Deploy containers onto Kind
# Hostname check is disabled for CI
echo "Starting helm install for gaffer-road-traffic"
pushd ./kubernetes/gaffer-road-traffic
helm install gaffer . -f ./values-insecure.yaml \
--set gaffer.hdfs.config.hdfsSite."dfs\.namenode\.datanode\.registration\.ip-hostname-check"=false
popd

echo "Starting helm install for gaffer-jhub"
pushd ./kubernetes/gaffer-jhub
helm install jhub . -f ./values-insecure.yaml
popd
