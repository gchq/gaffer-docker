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

# Update store properties files to point to the location of the Accumulo store to test against:
cat ~/conf/store.properties > ~/tmp/gaffer/store-implementation/accumulo-store/src/test/resources/store.properties
cat ~/conf/store2.properties > ~/tmp/gaffer/store-implementation/accumulo-store/src/test/resources/store2.properties
cat ~/conf/accumuloStoreClassicKeys.properties > ~/tmp/gaffer/store-implementation/accumulo-store/src/test/resources/accumuloStoreClassicKeys.properties

# Create ConfigMap
kubectl create configmap store-properties-config --from-file=~/conf/configMap.properties

# Run Integration Tests 
cd ~/tmp/gaffer/store-implementation/accumulo-store/
mvn clean install -pl :accumulo-store -am -Pquick
mvn run verify

