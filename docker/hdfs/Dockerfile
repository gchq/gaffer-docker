ARG BASE_IMAGE_NAME=debian
ARG BASE_IMAGE_TAG=stretch-20200224-slim

ARG BUILDER_IMAGE_NAME=alpine/git
ARG BUILDER_IMAGE_TAG=v2.24.1

ARG HADOOP_VERSION=3.2.1

FROM ${BUILDER_IMAGE_NAME}:${BUILDER_IMAGE_TAG} as hdfs-distribution
ARG HADOOP_VERSION

RUN dnf install -y java-1.8.0-openjdk maven patch

ARG HADOOP_CLONE_URL=https://github.com/apache/hadoop.git
COPY HADOOP-15129.patch .

# Allow users to provide their own Hadoop Distribution Tarball
COPY ./files/ .
# Otherwise, download official Hadoop Distribution Source code and apply patch
RUN if [ ! -f "./hadoop-${HADOOP_VERSION}.tar.gz" ]; then \
		git clone ${HADOOP_CLONE_URL}; \
		cd hadoop; \
		git checkout rel/hadoop-${HADOOP_VERSION}; \
		patch -p1 ../HADOOP-15129.patch; \
		mvn package -Pdist -DskipTests; \
		cp hadoop-dist/target/hadoop-${HADOOP_VERSION}.tar.gz ../hadoop-${HADOOP_VERSION}.tar.gz; \
		cd .. && rm -rf hadoop; \
	fi

FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}
ARG HADOOP_VERSION
ARG USER=hadoop
ARG GROUP=hadoop

RUN mkdir -p /usr/share/man/man1 && \
	apt update && \
	apt install -y \
		dumb-init \
		openjdk-8-jre-headless \
		libsnappy1v5 \
		libssl1.0-dev \
		libzstd1 \
		xmlstarlet \
	&& rm -rf /var/lib/apt/lists/*

COPY --from=hdfs-distribution --chown=root:root /git/hadoop-${HADOOP_VERSION}.tar.gz /opt

RUN groupadd ${GROUP} && useradd --home-dir /opt/hadoop --gid ${GROUP} --no-create-home --shell /bin/bash ${USER}

RUN cd /opt \
	&& tar -xf ./hadoop-${HADOOP_VERSION}.tar.gz \
	&& rm -rf ./hadoop-${HADOOP_VERSION}/share/doc \
	&& rm ./hadoop-${HADOOP_VERSION}.tar.gz \
	&& ln -s ./hadoop-${HADOOP_VERSION} ./hadoop \
	&& chown -R root:root ./hadoop/ \
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
