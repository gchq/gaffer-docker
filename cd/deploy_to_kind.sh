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

cd ./kubernetes/gaffer-road-traffic

# Deploy Images to Kind
kind load docker-image gchq/hdfs:3.2.1
kind load docker-image gchq/gaffer:1.14.0
kind load docker-image gchq/gaffer-rest:1.14.0
kind load docker-image gchq/gaffer-ui:1.14.0
kind load docker-image gchq/gaffer-road-traffic-loader:1.14.0
kind load docker-image gchq/gaffer-operation-runner:1.14.0

# Deploy containers onto Kind
# Hostname check is disabled for CI
echo "Starting helm install"
helm install gaffer . \
--set gaffer.accumulo.hdfs.config.hdfsSite."dfs\.namenode\.datanode\.registration\.ip-hostname-check"=false
