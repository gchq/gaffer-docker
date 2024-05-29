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

ARG ACCUMULO_VERSION=2.0.1
ARG HADOOP_VERSION=3.3.3
ARG ZOOKEEPER_VERSION=3.7.1

FROM ${BUILDER_IMAGE_NAME}:${BUILDER_IMAGE_TAG} as builder

ARG ACCUMULO_VERSION
ARG HADOOP_VERSION
ARG ZOOKEEPER_VERSION

ARG HADOOP_DOWNLOAD_URL="https://www.apache.org/dyn/closer.cgi?action=download&filename=hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz"
ARG HADOOP_BACKUP_DOWNLOAD_URL="https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz"

ARG ACCUMULO_DOWNLOAD_URL="https://www.apache.org/dyn/closer.cgi?action=download&filename=accumulo/${ACCUMULO_VERSION}/accumulo-${ACCUMULO_VERSION}-bin.tar.gz"
ARG ACCUMULO_BACKUP_DOWNLOAD_URL="https://archive.apache.org/dist/accumulo/${ACCUMULO_VERSION}/accumulo-${ACCUMULO_VERSION}-bin.tar.gz"

ARG ZOOKEEPER_DOWNLOAD_URL="https://www.apache.org/dyn/closer.cgi?action=download&filename=zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz"
ARG ZOOKEEPER_BACKUP_DOWNLOAD_URL="https://archive.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz"

RUN	apt -qq update && \
	apt -qq install -y \
		g++ \
		make \
		openjdk-8-jdk-headless \
		wget \
	&& rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/

# Allow users to provide their own builds of Accumulo, ZooKeeper and Hadoop
COPY ./files/ .
# Otherwise, download official distributions
RUN if [ ! -f "./accumulo-${ACCUMULO_VERSION}-bin.tar.gz" ]; then \
		(wget -nv -O ./accumulo-${ACCUMULO_VERSION}-bin.tar.gz ${ACCUMULO_DOWNLOAD_URL} || wget -nv -O ./accumulo-${ACCUMULO_VERSION}-bin.tar.gz ${ACCUMULO_BACKUP_DOWNLOAD_URL}); \
	fi && \
	if [ ! -f "./hadoop-${HADOOP_VERSION}.tar.gz" ]; then \
		(wget -nv -O ./hadoop-${HADOOP_VERSION}.tar.gz ${HADOOP_DOWNLOAD_URL} || wget -nv -O ./hadoop-${HADOOP_VERSION}.tar.gz ${HADOOP_BACKUP_DOWNLOAD_URL}); \
	fi && \
	if [ ! -f "./apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz" ]; then \
		(wget -nv -O ./apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz ${ZOOKEEPER_DOWNLOAD_URL} || wget -nv -O ./apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz ${ZOOKEEPER_BACKUP_DOWNLOAD_URL}); \
	fi

# Extract required files
RUN tar -xf ./accumulo-${ACCUMULO_VERSION}-bin.tar.gz accumulo-${ACCUMULO_VERSION}/bin/ accumulo-${ACCUMULO_VERSION}/lib/ && \
	rm -f ./accumulo-${ACCUMULO_VERSION}-bin.tar.gz && \
    # Build command dependent on ACCUMULO_VERSION
    if echo "$ACCUMULO_VERSION" | grep -q "^1.*$"; then ./accumulo-${ACCUMULO_VERSION}/bin/build_native_library.sh; else ./accumulo-${ACCUMULO_VERSION}/bin/accumulo-util build-native; fi && \
	tar -xf ./hadoop-${HADOOP_VERSION}.tar.gz \
		hadoop-${HADOOP_VERSION}/lib/native/ \
		hadoop-${HADOOP_VERSION}/share/hadoop/client/ \
		hadoop-${HADOOP_VERSION}/share/hadoop/common/lib/ \
		hadoop-${HADOOP_VERSION}/share/hadoop/hdfs/hadoop-hdfs-${HADOOP_VERSION}.jar \
		hadoop-${HADOOP_VERSION}/share/hadoop/yarn/ \
	&& \
	rm -f ./hadoop-${HADOOP_VERSION}.tar.gz && \
	cp ./hadoop-${HADOOP_VERSION}/share/hadoop/yarn/timelineservice/lib/commons-lang-*.jar ./hadoop-${HADOOP_VERSION}/share/hadoop/common/lib/ && \
	rm -rf ./hadoop-${HADOOP_VERSION}/share/hadoop/yarn && \
	tar -xf ./apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz --wildcards "apache-zookeeper-${ZOOKEEPER_VERSION}-bin/lib/zookeeper*.jar" && \
	rm -f ./apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz

FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}
ARG ACCUMULO_VERSION
ARG HADOOP_VERSION
ARG ZOOKEEPER_VERSION
ARG USER=accumulo
ARG GROUP=accumulo

RUN apt -qq update && \
	apt -qq install -y \
		dumb-init \
		openjdk-8-jre-headless \
		xmlstarlet \
	&& rm -rf /var/lib/apt/lists/*

COPY --from=builder --chown=root:root /accumulo-${ACCUMULO_VERSION} /opt/accumulo-${ACCUMULO_VERSION}/
COPY ./conf-${ACCUMULO_VERSION} /opt/accumulo-${ACCUMULO_VERSION}/conf
COPY --from=builder --chown=root:root /hadoop-${HADOOP_VERSION} /opt/hadoop-${HADOOP_VERSION}/
COPY --from=builder --chown=root:root /apache-zookeeper-${ZOOKEEPER_VERSION}-bin /opt/zookeeper-${ZOOKEEPER_VERSION}/

RUN groupadd ${GROUP} && useradd --home-dir /opt/accumulo --gid ${GROUP} --no-create-home --shell /bin/bash ${USER}

RUN cd /opt \
	&& ln -s ./accumulo-${ACCUMULO_VERSION} ./accumulo \
	&& ln -s ./hadoop-${HADOOP_VERSION} ./hadoop \
	&& ln -s ./zookeeper-${ZOOKEEPER_VERSION} ./zookeeper \
	&& mkdir -p -m 755 /var/log/accumulo \
	&& chown ${USER}:${GROUP} /var/log/accumulo

USER ${USER}
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/jre/
ENV ACCUMULO_HOME /opt/accumulo
ENV ACCUMULO_CONF_DIR ${ACCUMULO_HOME}/conf
ENV ACCUMULO_LOG_DIR /var/log/accumulo
ENV HADOOP_HOME /opt/hadoop
ENV HADOOP_CONF_DIR $HADOOP_HOME/etc/hadoop
ENV ZOOKEEPER_HOME /opt/zookeeper
ENV PATH $ACCUMULO_HOME/bin:$PATH

COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh", "accumulo"]
CMD ["help"]
