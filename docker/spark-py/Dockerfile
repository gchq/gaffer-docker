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

ARG BASE_IMAGE_NAME=debian
ARG BASE_IMAGE_TAG=bullseye-20201209-slim

FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

ARG SPARK_UID=185
ARG SPARK_HOME=/opt/spark
ARG SPARK_VERSION=3.0.1
ARG SPARK_DOWNLOAD_URL=https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.2.tgz

RUN mkdir -p /usr/share/man/man1 && \
	apt-get -qq update && \
	apt-get -qq install -y --no-install-recommends \
		dumb-init \
		openjdk-11-jre-headless \
		python3.8=3.8.6-1 \
		wget \
	&& rm -rf /var/lib/apt/lists /var/cache/apt/archives \
	&& ln -s /usr/bin/python3.8 /usr/bin/python3 \
	&& echo "${SPARK_UID}:x:${SPARK_UID}:0:spark uid:${SPARK_HOME}:/bin/false" >> /etc/passwd

RUN cd /opt && \
	wget -q ${SPARK_DOWNLOAD_URL} && \
	tar -xf ./spark-${SPARK_VERSION}-*.tgz && \
	rm ./spark-${SPARK_VERSION}-*.tgz && \
	ln -s ./spark-${SPARK_VERSION}-*/ ${SPARK_HOME}

ENV SPARK_HOME=${SPARK_HOME} \
	JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
USER ${SPARK_UID}
