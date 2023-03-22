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
accumulo_instance=$(cat conf/store.properties | grep accumulo.instance | sed -e 's/.*=\(.*\)/\1/')
accumulo_zookeepers=$(cat conf/store.properties | grep accumulo.zookeepers | sed -e 's/.*=\(.*\)/\1/')
accumulo_user=$(cat conf/store.properties | grep accumulo.user | sed -e 's/.*=\(.*\)/\1/')
accumulo_password=$(cat conf/store.properties | grep accumulo.password | sed -e 's/.*=\(.*\)/\1/')
store_properties=$(find /tmp/gaffer/store-implementation/accumulo-store/src/test/resources -name *.properties | grep -v cache)


for store in $store_properties; do
sed -i'' -e "s/gaffer.store.class=\(.*\)Mini\(.*\)/gaffer.store.class=\1\2/" $store
sed -i'' -e "s/accumulo.instance=.*/accumulo.instance=$accumulo_instance/" $store
sed -i'' -e "s/accumulo.zookeepers=.*/accumulo.zookeepers=$accumulo_zookeepers/" $store
sed -i'' -e "s/accumulo.user=.*/accumulo.user=$accumulo_user/" $store
sed -i'' -e "s/accumulo.password=.*/accumulo.password=$accumulo_password/" $store
done

# Needed for AddElementsFromHdfs tests
cp /opt/hadoop/conf/core-site.xml /tmp/gaffer/store-implementation/accumulo-store/src/test/resources

# Set correct LEGACY var based on Accumulo version
if echo "$ACCUMULO_VERSION" | grep -q "^1.*$"; then LEGACY=true; else LEGACY=false; fi

# Run Integration Tests 
cd /tmp/gaffer
echo "Running Maven Install"
echo "mvn -q clean install -Dlegacy=$LEGACY -pl :accumulo-store -am -Pquick"
mvn -q clean install -Dlegacy=$LEGACY -pl :accumulo-store -am -Pquick

echo "Running Maven tests"
echo "mvn -q verify -Dlegacy=$LEGACY -Dskip.surefire.tests -pl :accumulo-store -ff"
mvn -q verify -Dlegacy=$LEGACY -Dskip.surefire.tests -pl :accumulo-store -ff

