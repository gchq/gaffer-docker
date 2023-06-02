#!/bin/sh

# Copyright 2023 Crown Copyright
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

KEYTAB_PATH=/opt/hadoop/etc/hadoop/hadoop.keytab
PRINCIPAL=hadoop/$(hostname)

if [ "$DEBUG" -eq 1 ]; then
  export HADOOP_JAAS_DEBUG=true
  export HADOOP_OPTS="-Djava.net.preferIPv4Stack=true -Dsun.security.krb5.debug=true -Dsun.security.spnego.debug"
  echo "Hadoop Kerberos Debugging flags enabled (DEBUG=$DEBUG)"
fi

{
echo "add_entry -password -p $PRINCIPAL -k 1 -e aes256-cts"; sleep 0.2
echo $HADOOP_KRB_PASSWORD; sleep 0.2
echo list; sleep 0.2
echo "write_kt $KEYTAB_PATH"; sleep 0.2
echo exit
} | ktutil

# Call original HDFS entrypoint
exec /entrypoint.sh "$@"
