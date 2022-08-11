#!/bin/sh

# Copyright 2022 Crown Copyright
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

KEYTAB_PATH=$ACCUMULO_CONF_DIR/accumulo.keytab
PRINCIPLE=$ACCUMULO_PRINCIPLE/$(hostname)
FULL_PRINCIPLE=$ACCUMULO_PRINCIPLE/$(hostname)@GAFFER.DOCKER

if [ "$DEBUG" -eq 1 ]; then
  export ACCUMULO_GENERAL_OPTS="-Dsun.security.krb5.debug=true -Dsun.security.spnego.debug -Djava.security.debug=gssloginconfig,configfile,configparser,logincontext"
  echo "Accumulo Kerberos Debugging flags enabled (DEBUG=$DEBUG)"
fi

{
echo "add_entry -password -p $PRINCIPLE -k 1 -e aes256-cts"; sleep 0.2
echo $ACCUMULO_KRB_PASSWORD; sleep 0.2
echo list; sleep 0.2
echo "write_kt $KEYTAB_PATH"; sleep 0.2
echo exit
} | ktutil


# Copy generic config for all nodes into the config folder (cannot edit in place because it is read-only)
cp $ACCUMULO_CONF_DIR/generic/* $ACCUMULO_CONF_DIR
# Edit the site-config in place to set the principal for this node
xmlstarlet ed --inplace -u "/configuration/property/name[text()='general.kerberos.principal']/../value" -v $FULL_PRINCIPLE $ACCUMULO_CONF_DIR/accumulo-site.xml

# Below is a modified version of the standard Accumulo docker entrypoint.sh
# This cannot be called directly and reused because it is designed specifically for password auth

test -z "${ACCUMULO_INSTANCE_NAME}" && ACCUMULO_INSTANCE_NAME="accumulo"

if [ "$1" = "accumulo" ] && [ "$2" = "master" ]; then
	echo "\nInitializing Accumulo..."
	accumulo init --instance-name ${ACCUMULO_INSTANCE_NAME} --user $PRINCIPLE
fi

echo "\nRunning command: $@"
exec /usr/bin/dumb-init -- "$@"
