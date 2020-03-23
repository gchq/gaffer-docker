#!/bin/sh

if [ -z "${HADOOP_CONF_DIR}" ]; then
	HADOOP_CONF_DIR=${HADOOP_HOME}/etc/hadoop
fi

if [ "$1" = "hdfs" ] && [ "$2" = "namenode" ]; then
	NAME_DIRS=$(xmlstarlet sel -t -v "/configuration/property[name='dfs.namenode.name.dir']/value" ${HADOOP_CONF_DIR}/hdfs-site.xml)
	FIRST_NAME_DIR=${NAME_DIRS%%,*}

	if [ "${FIRST_NAME_DIR}" != "" ] && [ ! -d "${FIRST_NAME_DIR}" ]; then
		echo "Formatting HDFS NameNode volumes: ${NAME_DIRS}"
		hdfs namenode -format -force
	fi
fi

exec /usr/bin/dumb-init -- "$@"
