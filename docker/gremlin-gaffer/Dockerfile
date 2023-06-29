# Copyright 2023 Crown Copyright
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

ARG BUILDER_IMAGE_NAME=maven
ARG BUILDER_IMAGE_TAG=3.8.4-jdk-8

ARG BASE_IMAGE_NAME=tinkerpop/gremlin-server
ARG BASE_IMAGE_TAG=3.6.4

FROM ${BUILDER_IMAGE_NAME}:${BUILDER_IMAGE_TAG} as builder

ARG BASE_IMAGE_TAG
ARG GAFFER_VERSION=2.0.0
ARG GAFFER_DOWNLOAD_URL=https://repo1.maven.org/maven2
ARG GAFFER_GIT_REPO=https://github.com/gchq/Gaffer.git

WORKDIR /jars

# Allow users to provide their own JAR files
COPY ./files/ .
# Try to download required version from Maven Central, otherwise build from source
RUN	allFilesDownloaded="TRUE" && \
	if [ ! -f "./tinkerpop-${GAFFER_VERSION}-jar-with-dependencies.jar" ] && [ "${allFilesDownloaded}" = "TRUE" ]; then \
		wget -nv "${GAFFER_DOWNLOAD_URL}/uk/gov/gchq/gaffer/tinkerpop/${GAFFER_VERSION}/tinkerpop-${GAFFER_VERSION}-jar-with-dependencies.jar" || allFilesDownloaded="FALSE"; \
	fi && \
	if [ "${allFilesDownloaded}" = "FALSE" ]; then \
		git clone ${GAFFER_GIT_REPO} /tmp/gaffer && \
		cd /tmp/gaffer && \
		git checkout ${GAFFER_VERSION} || git checkout gaffer2-${GAFFER_VERSION} && \
		mvn clean package -Pquick -pl :tinkerpop && \
		if [ ! -f "/jars/tinkerpop-${GAFFER_VERSION}-jar-with-dependencies.jar" ]; then \
			cp ./library/tinkerpop/target/tinkerpop-${GAFFER_VERSION}-jar-with-dependencies.jar /jars; \
		fi \
	fi

FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}
COPY --from=builder --chown=root:root /jars/*.jar ext/gafferpop/plugin/
COPY ./conf/gafferpop/ conf/gafferpop/
COPY ./conf/gremlin-server-empty-gaffer.yaml conf/gremlin-server-empty-gaffer.yaml
CMD ["conf/gremlin-server-empty-gaffer.yaml"]
