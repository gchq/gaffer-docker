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

KEYTAB_PATH=$ACCUMULO_CONF_DIR/accumulo.keytab
PRINCIPAL=accumulo/$(hostname)
FULL_PRINCIPAL=$PRINCIPAL@GAFFER.DOCKER
GAFFER_FULL_PRINCIPAL=gaffer/$GAFFER_HOSTNAME@GAFFER.DOCKER

case "$ACCUMULO_AS_ROOT" in
 1) ROOT_PRINCIPAL=$FULL_PRINCIPAL ;;
 *) ROOT_PRINCIPAL=$GAFFER_FULL_PRINCIPAL ;;
esac

if [ "$DEBUG" -eq 1 ]; then
  export ACCUMULO_GENERAL_OPTS="-Dsun.security.krb5.debug=true -Dsun.security.spnego.debug -Djava.security.debug=gssloginconfig,configfile,configparser,logincontext"
  export ACCUMULO_JAVA_OPTS='-Dsun.security.krb5.debug=true'
  echo "Accumulo Kerberos Debugging flags enabled (DEBUG=$DEBUG)"
fi

{
echo "add_entry -password -p $PRINCIPAL -k 1 -e aes256-cts"; sleep 0.2
echo $ACCUMULO_KRB_PASSWORD; sleep 0.2
echo list; sleep 0.2
echo "write_kt $KEYTAB_PATH"; sleep 0.2
echo exit
} | ktutil

# Copy kerberos config for all nodes into the config folder (cannot edit in place because it is read-only)
cp $ACCUMULO_CONF_DIR/krb/* $ACCUMULO_CONF_DIR
# Copy accumulo-env into the config folder from non-krb folder
cp $ACCUMULO_CONF_DIR/non-krb/accumulo-env.sh $ACCUMULO_CONF_DIR

if echo "$ACCUMULO_VERSION" | grep -q "^1.*$"; then
  # Edit the site-config in place to set the principal for this node
  xmlstarlet ed --inplace -u "/configuration/property/name[text()='general.kerberos.principal']/../value" -v $FULL_PRINCIPAL $ACCUMULO_CONF_DIR/accumulo-site.xml
  # Copy required logging config from non-krb folder into the config folder
  cp $ACCUMULO_CONF_DIR/non-krb/log4j.properties $ACCUMULO_CONF_DIR
  cp $ACCUMULO_CONF_DIR/non-krb/*_logger.properties $ACCUMULO_CONF_DIR
else
  # Edit the Accumulo config properties in place to set the principal for this node
  sed -E -i '' -e "s|^(general.kerberos.principal=)(.*)$|\1$FULL_PRINCIPAL|g" $ACCUMULO_CONF_DIR/accumulo.properties
  # Copy required logging config from non-krb folder into the config folder
  cp $ACCUMULO_CONF_DIR/non-krb/log4j*properties $ACCUMULO_CONF_DIR
  # Suppress error messages which appear to be a bug relating to Kerberos in Accumulo 2.0.1
  echo "\nlog4j.logger.org.apache.thrift.server.TThreadPoolServer=FATAL" >> $ACCUMULO_CONF_DIR/log4j-service.properties
  echo "\nlog4j.logger.org.apache.thrift.server.TThreadPoolServer=FATAL" >> $ACCUMULO_CONF_DIR/log4j-monitor.properties
fi


# Below is a modified version of the standard Accumulo docker entrypoint.sh
# This cannot be called directly and reused because it is designed specifically for password auth

test -z "${ACCUMULO_INSTANCE_NAME}" && ACCUMULO_INSTANCE_NAME="accumulo"

if [ "$1" = "accumulo" ] && [ "$2" = "master" ]; then
	echo "Waiting 20 sec for HDFS to be ready..."
	sleep 20
	echo "\nInitializing Accumulo..."
	# '--user' sets the root user which had admin rights by default.
	# Default behaviour when $ACCUMULO_AS_ROOT != 1 is to use the principal
	# of Gaffer REST itself. This avoids a need to manually grant permissions
	# to Gaffer for creating tables etc. If $ACCUMULO_AS_ROOT is 1, then the
	# principal of the Accumulo master will be root, other users and their
	# permissions can then be added separately using an accumulo shell from
	# the master container.
	accumulo init --instance-name ${ACCUMULO_INSTANCE_NAME} --user $ROOT_PRINCIPAL
fi

# Accumulo 2 does not recognise Kerberos configuration when running 'accumulo $COMMAND'
# (other than 'accumulo init') When kinit is run first it is recognised. May be a bug
# in Accumulo or caused by unsupported direct use of Accumulo commands with Kerberos.
if echo "$ACCUMULO_VERSION" | grep -q "^2.*$"; then
  kinit -k -t /etc/accumulo/conf/accumulo.keytab $FULL_PRINCIPAL
fi

echo "\nRunning command: $@"
exec /usr/bin/dumb-init -- "$@"
