#!/bin/sh

# Copyright 2022-2023 Crown Copyright
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

echo "====================== Starting KDC ================================="

export REALM=GAFFER.DOCKER

# Create KDC Database
kdb5_util create -s -r $REALM -P `shuf -erz -n200  {A..z}`

# Add Principals (users)
kadmin.local -q "addprinc -pw $HADOOP_KRB_PASSWORD hadoop/hdfs-namenode.gaffer@$REALM"
kadmin.local -q "addprinc -pw $HADOOP_KRB_PASSWORD hadoop/hdfs-datanode.gaffer@$REALM"

kadmin.local -q "addprinc -pw $ZOOKEEPER_KRB_PASSWORD zookeeper/zookeeper.gaffer@$REALM"

kadmin.local -q "addprinc -pw $ACCUMULO_KRB_PASSWORD accumulo/accumulo-master.gaffer@$REALM"
kadmin.local -q "addprinc -pw $ACCUMULO_KRB_PASSWORD accumulo/accumulo-tserver.gaffer@$REALM"
kadmin.local -q "addprinc -pw $ACCUMULO_KRB_PASSWORD accumulo/accumulo-monitor.gaffer@$REALM"
kadmin.local -q "addprinc -pw $ACCUMULO_KRB_PASSWORD accumulo/accumulo-gc.gaffer@$REALM"

kadmin.local -q "addprinc -pw $GAFFER_KRB_PASSWORD gaffer/gaffer-rest.gaffer@$REALM"
kadmin.local -q "addprinc -pw $GAFFER_KRB_PASSWORD gaffer/gaffer-int.gaffer@$REALM"

krb5kdc -n
