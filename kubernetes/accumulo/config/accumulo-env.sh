#! /usr/bin/env bash

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


############################
# Variables that must be set
############################

## Accumulo logs directory. Referenced by logger config.
export ACCUMULO_LOG_DIR="${ACCUMULO_LOG_DIR:-${basedir}/logs}"
## Hadoop installation
export HADOOP_HOME="${HADOOP_HOME:-/path/to/hadoop}"
## Hadoop configuration
export HADOOP_CONF_DIR="${HADOOP_CONF_DIR:-${HADOOP_HOME}/etc/hadoop}"
## Zookeeper installation
export ZOOKEEPER_HOME="${ZOOKEEPER_HOME:-/path/to/zookeeper}"

##########################
# Build CLASSPATH variable
##########################

## Verify that Hadoop & Zookeeper installation directories exist
if [[ ! -d "$ZOOKEEPER_HOME" ]]; then
  echo "ZOOKEEPER_HOME=$ZOOKEEPER_HOME is not set to a valid directory in accumulo-env.sh"
  exit 1
fi
if [[ ! -d "$HADOOP_HOME" ]]; then
  echo "HADOOP_HOME=$HADOOP_HOME is not set to a valid directory in accumulo-env.sh"
  exit 1
fi

## Build using existing CLASSPATH, conf/ directory, dependencies in lib/, and external Hadoop & Zookeeper dependencies
if [[ -n "$CLASSPATH" ]]; then
  CLASSPATH="${CLASSPATH}:${conf}"
else
  CLASSPATH="${conf}"
fi
CLASSPATH="${CLASSPATH}:${lib}/*:${HADOOP_CONF_DIR}:${ZOOKEEPER_HOME}/*:${ZOOKEEPER_HOME}/lib/*:${HADOOP_HOME}/share/hadoop/client/*"
export CLASSPATH

##################################################################
# Build JAVA_OPTS variable. Defaults below work but can be edited.
##################################################################

## JVM options set for all processes. Extra options can be passed in by setting ACCUMULO_JAVA_OPTS to an array of options.
JAVA_OPTS=("${ACCUMULO_JAVA_OPTS[@]}"
  '-XX:+UseConcMarkSweepGC'
  '-XX:CMSInitiatingOccupancyFraction=75'
  '-XX:+CMSClassUnloadingEnabled'
  '-XX:OnOutOfMemoryError=kill -9 %p'
  '-XX:-OmitStackTraceInFastThrow'
  '-Djava.net.preferIPv4Stack=true'
  "-Daccumulo.native.lib.path=${lib}/native")

## Make sure Accumulo native libraries are built since they are enabled by default
# "${bin}"/accumulo-util build-native &> /dev/null

## JVM options set for individual applications
case "$cmd" in
  master)  JAVA_OPTS=("${JAVA_OPTS[@]}" '-Xmx512m' '-Xms512m') ;;
  monitor) JAVA_OPTS=("${JAVA_OPTS[@]}" '-Xmx256m' '-Xms256m') ;;
  gc)      JAVA_OPTS=("${JAVA_OPTS[@]}" '-Xmx256m' '-Xms256m') ;;
  tserver) JAVA_OPTS=("${JAVA_OPTS[@]}" '-Xmx768m' '-Xms768m') ;;
  *)       JAVA_OPTS=("${JAVA_OPTS[@]}" '-Xmx256m' '-Xms64m') ;;
esac

## JVM options set for logging. Review logj4 properties files to see how they are used.
JAVA_OPTS=("${JAVA_OPTS[@]}"
  "-Daccumulo.log.dir=${ACCUMULO_LOG_DIR}"
  "-Daccumulo.application=${cmd}${ACCUMULO_SERVICE_INSTANCE}_$(hostname)")

case "$cmd" in
  monitor)
    JAVA_OPTS=("${JAVA_OPTS[@]}" "-Dlog4j.configuration=log4j-monitor.properties")
    ;;
  gc|master|tserver|tracer)
    JAVA_OPTS=("${JAVA_OPTS[@]}" "-Dlog4j.configuration=log4j-service.properties")
    ;;
  *)
    # let log4j use its default behavior (log4j.xml, log4j.properties)
    true
    ;;
esac

export JAVA_OPTS

############################
# Variables set to a default
############################

export MALLOC_ARENA_MAX=${MALLOC_ARENA_MAX:-1}
## Add Hadoop native libraries to shared library paths given operating system
case "$(uname)" in
  Darwin) export DYLD_LIBRARY_PATH="${HADOOP_HOME}/lib/native:${DYLD_LIBRARY_PATH}" ;;
  *)      export LD_LIBRARY_PATH="${HADOOP_HOME}/lib/native:${LD_LIBRARY_PATH}" ;;
esac

###############################################
# Variables that are optional. Uncomment to set
###############################################

## Specifies command that will be placed before calls to Java in accumulo script
# export ACCUMULO_JAVA_PREFIX=""
