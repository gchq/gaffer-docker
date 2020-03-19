#!/bin/sh

test -z "${ACCUMULO_CONF_DIR}" && HADOOP_CONF_DIR="${ACCUMULO_HOME}/conf"
test -z "${ACCUMULO_INSTANCE_NAME}" && ACCUMULO_INSTANCE_NAME="accumulo"

if [ ${HDFS_READY} == "false" ]; then
	exit 1
fi

if [ "$1" = "accumulo" ] && [ "$2" = "master" ]; then
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
