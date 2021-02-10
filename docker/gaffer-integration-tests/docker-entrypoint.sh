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
store_class=$(cat conf/store.properties | grep store.class | sed -e 's/.*=\(.*\)/\1/')
accumulo_instance=$(cat conf/store.properties | grep accumulo.instance | sed -e 's/.*=\(.*\)/\1/')
accumulo_zookeepers=$(cat conf/store.properties | grep accumulo.zookeepers | sed -e 's/.*=\(.*\)/\1/')
accumulo_user=$(cat conf/store.properties | grep accumulo.user | sed -e 's/.*=\(.*\)/\1/')
accumulo_password=$(cat conf/store.properties | grep accumulo.password | sed -e 's/.*=\(.*\)/\1/')
store_properties=$(find /tmp/gaffer/store-implementation/accumulo-store/src/test/resources -name *.properties | grep -v cache)


for store in $store_properties; do
echo $store
sed -i'' -e "s/gaffer.store.class=.*/gaffer.store.class=$store_class/" $store
sed -i'' -e "s/accumulo.instance=.*/accumulo.instance=$accumulo_instance/" $store
sed -i'' -e "s/accumulo.zookeepers=.*/accumulo.zookeepers=$accumulo_zookeepers/" $store
sed -i'' -e "s/accumulo.user=.*/accumulo.user=$accumulo_user/" $store
sed -i'' -e "s/accumulo.password=.*/accumulo.password=$accumulo_password/" $store
cat $store
done

# Run Integration Tests 
cd /tmp/gaffer
mvn -q clean install -pl :accumulo-store -am -Pquick
mvn verify -pl :accumulo-store -ff

