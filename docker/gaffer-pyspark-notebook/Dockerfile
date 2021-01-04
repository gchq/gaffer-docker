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

ARG BASE_IMAGE_NAME=jupyter/scipy-notebook
ARG BASE_IMAGE_TAG=399cbb986c6b

FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

USER root

RUN apt-get -y update && apt-get install -y --no-install-recommends \
	ca-certificates-java \
	curl \
	less \
	openjdk-11-jre-headless \
&& rm -rf /var/lib/apt/lists/*

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
	unzip awscliv2.zip && \
	./aws/install && \
	rm -rf ./aws ./awscliv2.zip

ARG HADOOP_VERSION=3.3.0
ARG HADOOP_DOWNLOAD_URL=https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz

RUN cd /opt && \
	wget -q ${HADOOP_DOWNLOAD_URL} && \
	tar -xf ./hadoop-${HADOOP_VERSION}.tar.gz && \
	rm ./hadoop-${HADOOP_VERSION}.tar.gz && \
	ln -s ./hadoop-${HADOOP_VERSION} ./hadoop

# AWS Auth via K8s Service Accounts is only supported in AWS Java SDK 1.11.704+
# @see https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts-minimum-sdk.html
# Hadoop 3.3.0 ships with aws-java-sdk-bundle-1.11.563.jar :(

ARG AWS_JAVA_SDK_VERSION=1.11.834

RUN cd /opt/hadoop/share/hadoop/tools/lib && \
	rm -f aws-java-sdk-bundle-*.jar && \
	wget -q https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/${AWS_JAVA_SDK_VERSION}/aws-java-sdk-bundle-${AWS_JAVA_SDK_VERSION}.jar && \
	cd /opt/hadoop/libexec/ && \
	sed -i -E "s|aws-java-sdk-bundle-[0-9\.]+\.jar|aws-java-sdk-bundle-${AWS_JAVA_SDK_VERSION}\.jar|g" shellprofile.d/hadoop-aws.sh && \
	sed -i -E "s|aws-java-sdk-bundle-[0-9\.]+\.jar|aws-java-sdk-bundle-${AWS_JAVA_SDK_VERSION}\.jar|g" tools/hadoop-aws.sh

ARG SPARK_VERSION=3.0.0
ARG SPARK_DOWNLOAD_URL=https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-without-hadoop.tgz

RUN cd /opt && \
	wget -q ${SPARK_DOWNLOAD_URL} && \
	tar -xf ./spark-${SPARK_VERSION}-*.tgz && \
	rm ./spark-${SPARK_VERSION}-*.tgz && \
	ln -s ./spark-${SPARK_VERSION}-*/ ./spark

ARG FINDSPARK_VERSION=1.4.2
RUN pip install findspark==${FINDSPARK_VERSION} kubernetes

ARG KUBECTL_VERSION=1.20.0

RUN curl -fLo /bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
	chmod +x /bin/kubectl

ARG GAFFER_PYTHON_SHELL_VERSION=gaffer-tools-1.13.1
RUN git clone -b ${GAFFER_PYTHON_SHELL_VERSION} --depth 1 https://github.com/gchq/gaffer-tools && \
	pushd gaffer-tools/python-shell && \
	python setup.py install && \
	popd && \
	rm -rf gaffer-tools

RUN jupyter labextension install jupyterlab-plotly@4.10.0 && \
	rm -rf "/home/${NB_USER}/.cache/yarn"

COPY ./examples /examples

ENV PATH=/opt/spark/bin:/opt/hadoop/bin:$PATH \
	JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/ \
	HADOOP_HOME=/opt/hadoop \
	SPARK_HOME=/opt/spark \
	PYSPARK_DRIVER_PYTHON=python3 \
	PYSPARK_PYTHON=python3

USER $NB_UID