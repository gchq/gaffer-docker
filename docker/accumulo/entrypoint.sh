#!/bin/bash

# Copyright 2020-2022 Crown Copyright
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


test -z "${ACCUMULO_INSTANCE_NAME}" && ACCUMULO_INSTANCE_NAME="accumulo"

if [ "$1" = "accumulo" ] && [ "$2" = "master" ]; then
	# Try to find desired root password from trace config
	if [ -f "${ACCUMULO_CONF_DIR}/accumulo-site.xml" ]; then
		TRACE_USER=$(xmlstarlet sel -t -v "/configuration/property[name='trace.user']/value" ${ACCUMULO_CONF_DIR}/accumulo-site.xml)
		if [ "${TRACE_USER}" = "root" ]; then
			PASSWORD=$(xmlstarlet sel -t -v "/configuration/property[name='trace.token.property.password']/value" ${ACCUMULO_CONF_DIR}/accumulo-site.xml)
		fi
	fi

	# Try to find desired root password from client config
	if [ -f "${ACCUMULO_CONF_DIR}/client.conf" ]; then
		CLIENT_USERNAME=$(cat ${ACCUMULO_CONF_DIR}/client.conf | grep "auth.principal" | grep -v "^#" | cut -d= -f2)
		if [ "${CLIENT_USERNAME}" = "root" ]; then
			PASSWORD=$(cat ${ACCUMULO_CONF_DIR}/client.conf | grep "auth.token" | grep -v "^#" | cut -d= -f2)
		fi
	fi

	# Try to find desired root password from client config (accumulo 2)
	if [ -f "${ACCUMULO_CONF_DIR}/accumulo-client.properties" ]; then
		CLIENT_USERNAME=$(cat ${ACCUMULO_CONF_DIR}/accumulo-client.properties | grep "auth.principal" | grep -v "^#" | cut -d= -f2)
		if [ "${CLIENT_USERNAME}" = "root" ]; then
			PASSWORD=$(cat ${ACCUMULO_CONF_DIR}/accumulo-client.properties | grep "auth.token" | grep -v "^#" | cut -d= -f2)
		fi
	fi

	# Try to find desired root password from accumulo.properties (accumulo 2)
	if [ -f "${ACCUMULO_CONF_DIR}/accumulo.properties" ]; then
		TRACE_USER=$(cat ${ACCUMULO_CONF_DIR}/accumulo.properties | grep "trace.user" | grep -v "^#" | cut -d= -f2)
		if [ "${TRACE_USER}" = "root" ]; then
			PASSWORD=$(cat ${ACCUMULO_CONF_DIR}/accumulo.properties | grep "trace.token.property.password" | grep -v "^#" | cut -d= -f2)
		fi
	fi

	# Try to find desired root password from environment variable
	[ ! -z "${ACCUMULO_ROOT_PASSWORD}" ] && PASSWORD="${ACCUMULO_ROOT_PASSWORD}"

	if [ -z "${PASSWORD}" ]; then
		echo "Unable to determine what the Accumulo root user's password should be."
		echo "Please either set:"
		echo "- \$ACCUMULO_ROOT_PASSWORD environment variable"
		echo "- 'auth.token' property in ${ACCUMULO_CONF_DIR}/client.conf (if root is set for 'auth.principal')"
		echo "- 'trace.token.property.password' property in ${ACCUMULO_CONF_DIR}/accumulo-site.xml (if you are using root for the trace user)"
		exit 1
	fi

	# If possible, wait until all the HDFS instances that Accumulo will be using are available i.e. not in Safe Mode and directory is writeable
	[ -f "${ACCUMULO_CONF_DIR}/accumulo.properties" ] && ACCUMULO_VOLUMES=$(grep instance.volumes ${ACCUMULO_CONF_DIR}/accumulo.properties | cut -d= -f2)
	[[ -z "${ACCUMULO_VOLUMES}" && -f "${ACCUMULO_CONF_DIR}/accumulo-site.xml" ]] && ACCUMULO_VOLUMES=$(xmlstarlet sel -t -v "/configuration/property[name='instance.volumes']/value" ${ACCUMULO_CONF_DIR}/accumulo-site.xml)
	if [ ! -z "${ACCUMULO_VOLUMES}" ]; then
		HADOOP_CLASSPATH="${ACCUMULO_CONF_DIR}:${HADOOP_HOME}/share/hadoop/hdfs/*:${HADOOP_HOME}/share/hadoop/client/*:${HADOOP_HOME}/share/hadoop/common/lib/*"

		until [ "${ALL_VOLUMES_READY}" == "true" ] || [ $(( ATTEMPTS++ )) -gt 6 ]; do
			echo "$(date) - Waiting for all HDFS instances to be ready..."
			ALL_VOLUMES_READY="true"
			for ACCUMULO_VOLUME in ${ACCUMULO_VOLUMES//,/ }; do
				SAFE_MODE_CHECK="OFF"
				SAFE_MODE_CHECK_OUTPUT=$(java -cp ${HADOOP_CLASSPATH} org.apache.hadoop.hdfs.tools.DFSAdmin --fs ${ACCUMULO_VOLUME} -safemode get)
				echo ${SAFE_MODE_CHECK_OUTPUT} | grep -q "Safe mode is OFF"
				[ "$?" != "0" ] && ALL_VOLUMES_READY="false" && SAFE_MODE_CHECK="ON"

				WRITE_CHECK="writeable"
				java -cp ${HADOOP_CLASSPATH} org.apache.hadoop.fs.FsShell -mkdir -p ${ACCUMULO_VOLUME}
				java -cp ${HADOOP_CLASSPATH} org.apache.hadoop.fs.FsShell -test -w ${ACCUMULO_VOLUME}
				[ "$?" != "0" ] && ALL_VOLUMES_READY="false" && WRITE_CHECK="not writeable"

				echo ${ACCUMULO_VOLUME} "- Safe mode is" ${SAFE_MODE_CHECK} "-" ${WRITE_CHECK}
			done
			[ "${ALL_VOLUMES_READY}" == "true" ] || sleep 10
		done
		[ "${ALL_VOLUMES_READY}" != "true" ] && echo "$(date) - ERROR: Timed out waiting for HDFS instances to be ready..." && exit 1
	fi

	echo "Initializing Accumulo..."
	accumulo init --instance-name ${ACCUMULO_INSTANCE_NAME} --password ${PASSWORD}
fi

exec /usr/bin/dumb-init -- "$@"
