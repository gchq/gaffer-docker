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

# Wait a minute for Accumulo to be started and working
sleep 60

# Grant required permissions and auths to Gaffer user for integration tests

PRINCIPAL=accumulo/$(hostname)
FULL_PRINCIPAL=$PRINCIPAL@GAFFER.DOCKER
GAFFER_FULL_PRINCIPAL=$1

kinit -k -t /etc/accumulo/conf/accumulo.keytab $FULL_PRINCIPAL

echo "\nGranting permissions for Gaffer integration tests\n"

if echo "$ACCUMULO_VERSION" | grep -q "^2.*$"; then
  ACCUMULO_SHELL_CMD="accumulo shell --config-file accumulo-shell-client.properties -e"
else
  ACCUMULO_SHELL_CMD="accumulo shell -e"
fi

$ACCUMULO_SHELL_CMD "createuser $GAFFER_FULL_PRINCIPAL"
$ACCUMULO_SHELL_CMD "grant System.CREATE_TABLE -s -u $GAFFER_FULL_PRINCIPAL"
$ACCUMULO_SHELL_CMD "grant System.DROP_TABLE -s -u $GAFFER_FULL_PRINCIPAL"
$ACCUMULO_SHELL_CMD "grant System.ALTER_TABLE -s -u $GAFFER_FULL_PRINCIPAL"
$ACCUMULO_SHELL_CMD "setauths -s vis1,vis2,publicVisibility,privateVisibility,public,private -u $GAFFER_FULL_PRINCIPAL"
