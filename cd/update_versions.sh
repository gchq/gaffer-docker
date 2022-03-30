#!/bin/bash

# Copyright 2020 Crown Copyright
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

if [ ! -z "$1" ]; then
	APP_VERSION=$1
fi

# This sets the values for:
# HADOOP_VERSION
# GAFFER_VERSION
# GAFFER_TOOLS_VERSION
# SPARK_VERSION
source ./docker/gaffer-pyspark-notebook/.env
# JHUB_OPTIONS_SERVER_VERSION
source docker/gaffer-jhub-options-server/get-version.sh

# hdfs
[ ! -z "${APP_VERSION}" ] && yq eval ".version = \"${APP_VERSION}\"" -i ./kubernetes/hdfs/Chart.yaml
yq eval ".appVersion = \"${HADOOP_VERSION}\"" -i ./kubernetes/hdfs/Chart.yaml

yq eval ".namenode.tag = \"${HADOOP_VERSION}\"" -i ./kubernetes/hdfs/values.yaml
yq eval ".datanode.tag = \"${HADOOP_VERSION}\"" -i ./kubernetes/hdfs/values.yaml
yq eval ".shell.tag = \"${HADOOP_VERSION}\"" -i ./kubernetes/hdfs/values.yaml

# accumulo
[ ! -z "${APP_VERSION}" ] && yq eval ".version = \"${APP_VERSION}\"" -i ./kubernetes/accumulo/Chart.yaml
[ ! -z "${APP_VERSION}" ] && yq eval ".dependencies[1].version = \"^${APP_VERSION}\"" -i ./kubernetes/accumulo/Chart.yaml
yq eval ".appVersion = \"${ACCUMULO_VERSION}\"" -i ./kubernetes/accumulo/Chart.yaml
yq eval ".image.tag = \"${ACCUMULO_VERSION}\"" -i ./kubernetes/accumulo/values.yaml

# gaffer
[ ! -z "${APP_VERSION}" ] && yq eval ".version = \"${APP_VERSION}\"" -i ./kubernetes/gaffer/Chart.yaml
yq eval ".appVersion = \"${GAFFER_VERSION}\"" -i ./kubernetes/gaffer/Chart.yaml
[ ! -z "${APP_VERSION}" ] && yq eval ".dependencies[0].version = \"^${APP_VERSION}\"" -i ./kubernetes/gaffer/Chart.yaml

yq eval ".accumulo.image.tag = \"${GAFFER_VERSION}\"" -i ./kubernetes/gaffer/values.yaml
yq eval ".api.image.tag = \"${GAFFER_VERSION}\"" -i ./kubernetes/gaffer/values.yaml

# gaffer-road-traffic
[ ! -z "${APP_VERSION}" ] && yq eval ".version = \"${APP_VERSION}\"" -i ./kubernetes/gaffer-road-traffic/Chart.yaml
yq eval ".appVersion = \"${GAFFER_VERSION}\"" -i ./kubernetes/gaffer-road-traffic/Chart.yaml
[ ! -z "${APP_VERSION}" ] && yq eval ".dependencies[0].version = \"^${APP_VERSION}\"" -i ./kubernetes/gaffer-road-traffic/Chart.yaml

yq eval ".loader.image.tag = \"${GAFFER_VERSION}\"" -i ./kubernetes/gaffer-road-traffic/values.yaml

# gaffer-jhub
[ ! -z "${APP_VERSION}" ] && yq eval ".version = \"${APP_VERSION}\"" -i ./kubernetes/gaffer-jhub/Chart.yaml

yq eval ".jupyterhub.singleuser.profileList[1].description = \"Python 3, Hadoop ${HADOOP_VERSION}, Spark ${SPARK_VERSION}, AWS CLI 2, kubectl 1.20.0, gafferpy ${GAFFER_TOOLS_VERSION}\"" -i ./kubernetes/gaffer-jhub/values.yaml
yq eval ".jupyterhub.singleuser.profileList[1].spark_image = \"gchq/spark-py:${SPARK_VERSION}\"" -i ./kubernetes/gaffer-jhub/values.yaml
yq eval ".jupyterhub.singleuser.profileList[1].kubespawner_override.image = \"gchq/gaffer-pyspark-notebook:${GAFFER_VERSION}\"" -i ./kubernetes/gaffer-jhub/values.yaml
yq eval ".optionsServer.image.tag = \"${JHUB_OPTIONS_SERVER_VERSION}\"" -i ./kubernetes/gaffer-jhub/values.yaml
yq eval ".testImages.python.tag = \"${GAFFER_VERSION}\"" -i ./kubernetes/gaffer-jhub/values.yaml
