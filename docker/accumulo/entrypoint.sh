#!/bin/sh

test -z "${ACCUMULO_CONF_DIR}" && HADOOP_CONF_DIR="${ACCUMULO_HOME}/conf"
test -z "${ACCUMULO_INSTANCE_NAME}" && ACCUMULO_INSTANCE_NAME="accumulo"

HADOOP_HOME=/opt/hadoop

if [ "$1" = "accumulo" ] && [ "$2" = "master" ]; then
	# If possible, wait until all the HDFS instances that Accumulo will be using are available i.e. not in Safe Mode
	ACCUMULO_VOLUMES=$(xmlstarlet sel -t -v "/configuration/property[name='instance.volumes']/value" ${ACCUMULO_CONF_DIR}/accumulo-site.xml)
	if [ ! -z "${ACCUMULO_VOLUMES}" ]; then
		until [ "${ALL_VOLUMES_READY}" == "true" ] || [ $(( ATTEMPTS++ )) -gt 6 ]; do
			echo "$(date) - Waiting for all HDFS instances to be ready..."
			ALL_VOLUMES_READY="true"
			for ACCUMULO_VOLUME in ${ACCUMULO_VOLUMES//,/ }; do
				SAFE_MODE_CHECK=$(java -cp ${ACCUMULO_CONF_DIR}:${HADOOP_HOME}/share/hadoop/hdfs/*:${HADOOP_HOME}/share/hadoop/client/*:${HADOOP_HOME}/share/hadoop/common/lib/* org.apache.hadoop.hdfs.tools.DFSAdmin --fs ${ACCUMULO_VOLUME} -safemode get)
				echo ${ACCUMULO_VOLUME} "-" ${SAFE_MODE_CHECK}
				echo ${SAFE_MODE_CHECK} | grep -q "Safe mode is OFF" || ALL_VOLUMES_READY="false"
			done
			[ "${ALL_VOLUMES_READY}" == "true" ] || sleep 10
		done
		[ "${ALL_VOLUMES_READY}" == "true" ] || (echo "$(date) - ERROR: Timed out waiting for HDFS instances to be ready..." && exit 1)
	fi

	# Try to find desired root password from environment variable
	PASSWORD="${ACCUMULO_ROOT_PASSWORD}"

	# Try to find desired root password from config
	TRACE_USER=$(xmlstarlet sel -t -v "/configuration/property[name='trace.user']/value" ${ACCUMULO_CONF_DIR}/accumulo-site.xml)
	if [ "${TRACE_USER}" = "root" ]; then
		PASSWORD=$(xmlstarlet sel -t -v "/configuration/property[name='trace.token.property.password']/value" ${ACCUMULO_CONF_DIR}/accumulo-site.xml)
	fi

	if [ -z "${PASSWORD}" ]; then
		echo "Unable to determine what the Accumulo root user's password should be."
		echo "Please set \$ACCUMULO_ROOT_PASSWORD or the 'trace.token.property.password' property in ${ACCUMULO_CONF_DIR}/accumulo-site.xml (if you are using root for the trace user)"
		exit 1
	fi

	echo "Initializing Accumulo..."
	accumulo init --instance-name ${ACCUMULO_INSTANCE_NAME} --password ${PASSWORD}
fi

exec /usr/bin/dumb-init -- "$@"
