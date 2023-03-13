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

KEYTAB_PATH=/conf/zookeeper.keytab
PRINCIPAL=zookeeper/$(hostname).gaffer

{
echo "add_entry -password -p $PRINCIPAL -k 1 -e aes256-cts"; sleep 0.2
echo $ZOOKEEPER_KRB_PASSWORD; sleep 0.2
echo list; sleep 0.2
echo "write_kt $KEYTAB_PATH"; sleep 0.2
echo exit
} | ktutil

# Zookeeper switches user to its own user, which needs to own the keytab
chown zookeeper:zookeeper $KEYTAB_PATH

# Call original Zookeeper entrypoint
exec /docker-entrypoint.sh "$@"
