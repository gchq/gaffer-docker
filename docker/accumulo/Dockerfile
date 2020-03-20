
ARG BUILDER_IMAGE_NAME=debian
ARG BUILDER_IMAGE_TAG=stretch-20200224-slim

ARG BASE_IMAGE_NAME=debian
ARG BASE_IMAGE_TAG=stretch-20200224-slim

ARG ACCUMULO_VERSION=1.9.3
ARG HADOOP_VERSION=3.2.1
ARG ZOOKEEPER_VERSION=3.6.0

FROM ${BUILDER_IMAGE_NAME}:${BUILDER_IMAGE_TAG} as builder

ARG ACCUMULO_VERSION
ARG HADOOP_VERSION
ARG ZOOKEEPER_VERSION

ARG ACCUMULO_DOWNLOAD_URL=https://archive.apache.org/dist/accumulo/${ACCUMULO_VERSION}/accumulo-${ACCUMULO_VERSION}-bin.tar.gz
ARG HADOOP_DOWNLOAD_URL=https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz
ARG ZOOKEEPER_DOWNLOAD_URL=https://archive.apache.org/dist/zookeeper/zookeeper-${ZOOKEEPER_VERSION}/apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz

RUN mkdir -p /usr/share/man/man1 && \
	apt update && \
	apt install -y \
		curl \
		g++ \
		make \
		openjdk-8-jdk-headless \
	&& rm -rf /var/lib/apt/lists/*

ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64/

# Allow users to provide their own builds of Accumulo, ZooKeeper and Hadoop
COPY ./files/ .
# Otherwise, download official distributions
RUN if [ ! -f "./accumulo-${ACCUMULO_VERSION}-bin.tar.gz" ]; then \
		curl -fLO ${ACCUMULO_DOWNLOAD_URL}; \
	fi && \
	if [ ! -f "./hadoop-${HADOOP_VERSION}.tar.gz" ]; then \
		curl -fLO ${HADOOP_DOWNLOAD_URL}; \
	fi && \
	if [ ! -f "./apache-zookeeper-${ZOOKEEPER_VERSION}-bin.tar.gz" ]; then \
		curl -fLO ${ZOOKEEPER_DOWNLOAD_URL}; \
	fi

# Extract required files
RUN tar -xf ./accumulo-${ACCUMULO_VERSION}-bin.tar.gz accumulo-${ACCUMULO_VERSION}/bin/ accumulo-${ACCUMULO_VERSION}/lib/ && \
	rm -f ./accumulo-${ACCUMULO_VERSION}-bin.tar.gz && \
	./accumulo-${ACCUMULO_VERSION}/bin/build_native_library.sh && \
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

RUN mkdir -p /usr/share/man/man1 && \
	apt update && \
	apt install -y \
		dumb-init \
		openjdk-8-jre-headless \
		xmlstarlet \
	&& rm -rf /var/lib/apt/lists/*

COPY --from=builder --chown=root:root /accumulo-${ACCUMULO_VERSION} /opt/accumulo-${ACCUMULO_VERSION}/
COPY ./conf /opt/accumulo-${ACCUMULO_VERSION}/conf
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
ENV PATH $ACCUMULO_HOME/bin:$PATH

COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh", "accumulo"]
CMD ["help"]
