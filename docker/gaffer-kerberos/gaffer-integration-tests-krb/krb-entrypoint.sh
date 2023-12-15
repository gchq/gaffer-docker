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

set -ex

# Show verbose Hadoop Kerberos auth information
if [ $DEBUG -eq 1 ]; then
  export HADOOP_JAAS_DEBUG=true
  export HADOOP_OPTS="-Djava.net.preferIPv4Stack=true -Dsun.security.krb5.debug=true -Dsun.security.spnego.debug"
  echo "Debugging flag enabled (DEBUG=$DEBUG), additional Kerberos details will be printed"
fi

KEYTAB_PATH=/tmp/gaffer.keytab
PRINCIPAL=gaffer/$(hostname)
FULL_PRINCIPAL=gaffer/$(hostname)@GAFFER.DOCKER

{
echo "add_entry -password -p $PRINCIPAL -k 1 -e aes256-cts"; sleep 0.2
echo $GAFFER_KRB_PASSWORD; sleep 0.2
echo list; sleep 0.2
echo "write_kt $KEYTAB_PATH"; sleep 0.2
echo exit
} | ktutil

# Update store properties files to point to the location of the Accumulo store to test against:
accumulo_instance=$(cat conf/store.properties | grep accumulo.instance | sed -e 's/.*=\(.*\)/\1/')
accumulo_zookeepers=$(cat conf/store.properties | grep accumulo.zookeepers | sed -e 's/.*=\(.*\)/\1/')
store_properties=$(find /tmp/gaffer/store-implementation/accumulo-store/src/test/resources -name *.properties | grep -v cache)

for store in $store_properties; do
sed -i'' -e "s/gaffer.store.class=\(.*\)Mini\(.*\)/gaffer.store.class=\1\2/" $store
sed -i'' -e "s/accumulo.instance=.*/accumulo.instance=$accumulo_instance/" $store
sed -i'' -e "s/accumulo.zookeepers=.*/accumulo.zookeepers=$accumulo_zookeepers/" $store
echo accumulo.kerberos.principal=$FULL_PRINCIPAL >> $store
echo accumulo.kerberos.keytab=$KEYTAB_PATH >> $store
echo accumulo.kerberos.enable=true >> $store
done

# Needed for AddElementsFromHdfs tests
cp /opt/hadoop/conf/core-site.xml /tmp/gaffer/store-implementation/accumulo-store/src/test/resources/
cp /opt/hadoop/conf/hdfs-site.xml /tmp/gaffer/store-implementation/accumulo-store/src/test/resources/

# Required for Hadoop to find its Native Libraries which Kerberos auth cannot work without
cp /tmp/hadoop/native/lib* /usr/lib/

# Set correct LEGACY var based on Accumulo version
if echo "$ACCUMULO_VERSION" | grep -q "^1.*$"; then LEGACY=true; else LEGACY=false; fi

# Run Integration Tests
cd /tmp/gaffer
# Compile Tests
mvn -q clean install -Dlegacy=$LEGACY -pl :accumulo-store -am -Pquick
# Run Tests without quiet output if GAFFER_DEBUG enabled
if [ $GAFFER_DEBUG -eq 1 ]; then
  # Replace log config with a config which uses INFO level, this additional info may help for Gaffer ticket #3134
  cp /tests/conf/log4j.xml /tmp/gaffer/store-implementation/accumulo-store/src/test/resources/
  mvn verify -Dlegacy=$LEGACY -ntp -Dskip.surefire.tests -Dmaven.test.failure.ignore=true -Dmaven.main.skip=true -DtrimStackTrace=false -DuseFile=false -Pcoverage -pl :accumulo-store
else
  mvn -q verify -Dlegacy=$LEGACY -Dskip.surefire.tests -pl :accumulo-store -ff
fi
