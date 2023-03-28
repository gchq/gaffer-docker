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

# Update store properties files to point to the location of the Accumulo store to test against:
cp conf/tester/store.properties /tmp/gaffer/store-implementation/federated-store/src/test/resources/properties/singleUseAccumuloStore.properties

# Overwrite FederatedStore IT class with a custom one that will proxy to the FederatedStore in container
cp conf/tester/PublicAccessPredefinedFederatedStore.java /tmp/gaffer/store-implementation/federated-store/src/test/java/uk/gov/gchq/gaffer/federatedstore/PublicAccessPredefinedFederatedStore.java

# Create ProxyStoreProperties used by PublicAccessPredefinedFederatedStore
cp conf/proxy/store.properties /tmp/gaffer/store-implementation/federated-store/src/test/resources/proxyStore.properties

# Run Integration Tests
cd /tmp/gaffer
echo "Running Maven Install"
echo "mvn -q clean install -pl :federated-store -am -Pquick"
mvn -q clean install -pl :federated-store -am -Pquick

# Only run core ITs and skip FederatedStore specific ones, like FederatedAdminIT.
# This is because they are not correctly setup to work through a proxy:
# they expect all the Accumulo information to be directly available in the GraphStorage cache
echo "Running Maven tests"
echo "mvn -q integration-test -Dit.test=FederatedStoreITs -pl :federated-store -Dskip.surefire.tests=true -Dmaven.javadoc.skip=true -Dpmd.skip=true -Dspotbugs.skip=true -Dcheckstyle.skip=true -ff"
mvn -q integration-test -Dit.test=FederatedStoreITs -pl :federated-store -Dskip.surefire.tests=true -Dmaven.javadoc.skip=true -Dpmd.skip=true -Dspotbugs.skip=true -Dcheckstyle.skip=true -ff
