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
cd ~/store-implementation/accumulo-store/src/test/resources/
sed -i '16 a gaffer.store.properties.class=uk.gov.gchq.gaffer.accumulostore.AccumuloProperties' store.properties
sed -i 's/localhost/localhost:58630/g' store.properties
sed -i 's/=user/=root/g' store.properties
sed -i 's/standardInstance/instance/g' store.properties
sed -i '16 a gaffer.store.properties.class=uk.gov.gchq.gaffer.accumulostore.AccumuloProperties' store2.properties
sed -i 's/localhost/localhost:58630/g' store2.properties
sed -i 's/=user/=root/g' store2.properties
sed -i 's/standardInstance/instance/g' store2.properties
sed -i 's/localhost/localhost:58630/g' accumuloStoreClassicKeys.properties
sed -i 's/=user/=root/g' accumuloStoreClassicKeys.properties
sed -i 's/standardInstance/instance/g' accumuloStoreClassicKeys.properties
sed -i '16 a gaffer.store.properties.class=uk.gov.gchq.gaffer.accumulostore.AccumuloProperties' accumuloStoreClassicKeys.properties 

# Run Integration Tests 
cd ../../../
mvn clean install -pl :accumulo-store -am -Pquick
mvn run test

