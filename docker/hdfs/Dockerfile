# Copyright 2020-2024 Crown Copyright
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

ARG BUILDER_IMAGE_NAME=ubuntu
ARG BUILDER_IMAGE_TAG=noble-20240429

ARG BASE_IMAGE_NAME=ubuntu
ARG BASE_IMAGE_TAG=noble-20240429

ARG HADOOP_VERSION=3.3.3

FROM ${BUILDER_IMAGE_NAME}:${BUILDER_IMAGE_TAG} as builder
ARG HADOOP_VERSION
ARG HADOOP_DOWNLOAD_URL="https://www.apache.org/dyn/closer.cgi?action=download&filename=hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz"
ARG HADOOP_BACKUP_DOWNLOAD_URL="https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz"
ARG HADOOP_APPLY_PATCHES=false
COPY ./files/ /
RUN ./build-hadoop.sh

FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}
ARG HADOOP_VERSION
ARG USER=hadoop
ARG GROUP=hadoop

RUN apt -qq update && \
	apt -qq install -y \
		dumb-init \
		openjdk-8-jre-headless \
		libsnappy1v5 \
		libssl-dev \
		libzstd1 \
		xmlstarlet \
		curl \
		jq \
	&& rm -rf /var/lib/apt/lists/*

RUN groupadd ${GROUP} && useradd --home-dir /opt/hadoop --gid ${GROUP} --no-create-home --shell /bin/bash ${USER}

COPY --from=builder --chown=root:root /hadoop-${HADOOP_VERSION} /opt/hadoop-${HADOOP_VERSION}

RUN cd /opt \
	&& ln -s ./hadoop-${HADOOP_VERSION} ./hadoop \
	&& mkdir -p -m 755 /var/log/hadoop \
	&& chown ${USER}:${GROUP} /var/log/hadoop

COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh", "hdfs"]

RUN for i in $(seq 1 8); do mkdir -p -m 750 /data${i} && chown ${USER}:${GROUP} /data${i}; done
VOLUME /data1 /data2 /data3 /data4 /data5 /data6 /data7 /data8

USER ${USER}
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/jre/
ENV HADOOP_HOME /opt/hadoop
ENV HADOOP_LOG_DIR /var/log/hadoop
ENV PATH $HADOOP_HOME/bin:$PATH

RUN hadoop checknative -a || true
