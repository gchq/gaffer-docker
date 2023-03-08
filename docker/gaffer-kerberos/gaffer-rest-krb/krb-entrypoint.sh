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

KEYTAB_PATH=/gaffer/config/gaffer.keytab
PRINCIPAL=$GAFFER_PRINCIPAL/$(hostname)
FULL_PRINCIPAL=$GAFFER_PRINCIPAL/$(hostname)@GAFFER.DOCKER


{
echo "add_entry -password -p $PRINCIPAL -k 1 -e aes256-cts"; sleep 0.2
echo $GAFFER_KRB_PASSWORD; sleep 0.2
echo list; sleep 0.2
echo "write_kt $KEYTAB_PATH"; sleep 0.2
echo exit
} | ktutil

echo "ACCUMULO_CLIENT_CONF_PATH=$ACCUMULO_CLIENT_CONF_PATH\n"

exec java -Dloader.path=/gaffer/jars/lib -jar jars/rest.jar