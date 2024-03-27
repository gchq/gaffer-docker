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

ARG BASE_IMAGE_NAME=jupyter/scipy-notebook
ARG BASE_IMAGE_TAG=c26bf69c148d

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

ARG HADOOP_VERSION=3.3.3
ARG HADOOP_DOWNLOAD_URL="https://www.apache.org/dyn/closer.cgi?action=download&filename=hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz"
ARG HADOOP_BACKUP_DOWNLOAD_URL="https://archive.apache.org/dist/hadoop/common/hadoop-${HADOOP_VERSION}/hadoop-${HADOOP_VERSION}.tar.gz"

RUN cd /opt && \
	(wget -nv -O ./hadoop-${HADOOP_VERSION}.tar.gz ${HADOOP_DOWNLOAD_URL} || wget -nv -O ./hadoop-${HADOOP_VERSION}.tar.gz ${HADOOP_BACKUP_DOWNLOAD_URL}) && \
	tar -xf ./hadoop-${HADOOP_VERSION}.tar.gz && \
	rm ./hadoop-${HADOOP_VERSION}.tar.gz && \
	ln -s ./hadoop-${HADOOP_VERSION} ./hadoop && \
	rm -rf ./hadoop/share/doc

ARG SPARK_VERSION=3.1.2
ARG SPARK_DOWNLOAD_URL="https://www.apache.org/dyn/closer.cgi?action=download&filename=spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-without-hadoop.tgz"
ARG SPARK_BACKUP_DOWNLOAD_URL="https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-without-hadoop.tgz"

RUN cd /opt && \
	(wget -nv -O ./spark-${SPARK_VERSION}.tgz ${SPARK_DOWNLOAD_URL} || wget -nv -O ./spark-${SPARK_VERSION}.tgz ${SPARK_BACKUP_DOWNLOAD_URL}) && \
	tar -xf ./spark-${SPARK_VERSION}.tgz && \
	rm ./spark-${SPARK_VERSION}.tgz && \
	ln -s ./spark-${SPARK_VERSION}-*/ ./spark

ARG FINDSPARK_VERSION=2.0.0
ARG KUBERNETES_PYTHON_VERSION=21.7.0
RUN pip install findspark==${FINDSPARK_VERSION} kubernetes==${KUBERNETES_PYTHON_VERSION}

ARG KUBECTL_VERSION=1.23.0
RUN curl -fLo /bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl && \
	chmod +x /bin/kubectl

ARG GAFFERPY_VERSION=gafferpy-2.2.0
RUN git clone -b ${GAFFERPY_VERSION} --depth 1 https://github.com/gchq/gafferpy && \
	pushd gafferpy && \
	python setup.py install && \
	popd && \
	rm -rf gafferpy

RUN jupyter labextension install jupyterlab-plotly@5.5.0 && \
	rm -rf "/home/${NB_USER}/.cache/yarn"

COPY ./examples /examples

ENV PATH=/opt/spark/bin:/opt/hadoop/bin:$PATH \
	JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64/ \
	HADOOP_HOME=/opt/hadoop \
	SPARK_HOME=/opt/spark \
	PYSPARK_DRIVER_PYTHON=python3 \
	PYSPARK_PYTHON=python3

USER $NB_UID
