# Copyright 2022-2023 Crown Copyright
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

ARG BASE_IMAGE_NAME=gchq/hdfs
ARG BASE_IMAGE_TAG=3.3.3

ARG USER=hadoop
ARG GROUP=hadoop

FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

USER root
RUN DEBIAN_FRONTEND=noninteractive apt-get -qq update && \
	DEBIAN_FRONTEND=noninteractive apt-get -qq install -y \
		krb5-user \
        jsvc && \
    apt-get -qq clean \
	&& rm -rf /var/lib/apt/lists/*

RUN chown -R ${USER}:${GROUP} /opt/hadoop/etc/hadoop && \
    echo "export HDFS_DATANODE_SECURE_USER=hadoop" >> /opt/hadoop/etc/hadoop/hadoop-env.sh && \
    echo "export JSVC_HOME=/usr/bin" >> /opt/hadoop/etc/hadoop/hadoop-env.sh
USER ${USER}

COPY ./krb-entrypoint.sh /
ENTRYPOINT ["/krb-entrypoint.sh", "hdfs"]
