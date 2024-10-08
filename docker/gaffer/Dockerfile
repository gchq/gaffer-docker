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

ARG BUILDER_IMAGE_NAME=maven
ARG BUILDER_IMAGE_TAG=3.9-eclipse-temurin-8

ARG BASE_IMAGE_NAME=gchq/accumulo
ARG BASE_IMAGE_TAG=2.0.1

FROM ${BUILDER_IMAGE_NAME}:${BUILDER_IMAGE_TAG} as builder

ARG BASE_IMAGE_TAG
ARG GAFFER_VERSION=2.3.0
ARG GAFFER_LIBS=bitmap-library,sketches-library,time-library
ARG GAFFER_DOWNLOAD_URL=https://repo1.maven.org/maven2
ARG GAFFER_GIT_REPO=https://github.com/gchq/Gaffer.git

WORKDIR /jars

# Allow users to provide their own JAR files
COPY ./files/ .
# Try to download required version from Maven Central, otherwise build from source
RUN	allFilesDownloaded="TRUE" && \
    if echo "$BASE_IMAGE_TAG" | grep -q "^1.*$"; then allFilesDownloaded="FALSE"; fi && \
	if [ ! -f "./accumulo-store-${GAFFER_VERSION}-iterators.jar" ] && [ "${allFilesDownloaded}" = "TRUE" ]; then \
		wget -nv "${GAFFER_DOWNLOAD_URL}/uk/gov/gchq/gaffer/accumulo-store/${GAFFER_VERSION}/accumulo-store-${GAFFER_VERSION}-iterators.jar" || allFilesDownloaded="FALSE"; \
	fi && \
	for lib in $(echo ${GAFFER_LIBS} | tr , ' '); do \
		if [ ! -f "./${lib}-${GAFFER_VERSION}-deploy.jar" ] && [ "${allFilesDownloaded}" = "TRUE" ]; then \
			wget -nv "${GAFFER_DOWNLOAD_URL}/uk/gov/gchq/gaffer/${lib}/${GAFFER_VERSION}/${lib}-${GAFFER_VERSION}-deploy.jar" || allFilesDownloaded="FALSE"; \
		fi \
	done && \
	if [ "${allFilesDownloaded}" = "FALSE" ]; then \
        # Set legacy option based on BASE_IMAGE_TAG (Accumulo version)
        if echo "$BASE_IMAGE_TAG" | grep -q "^2.*$"; then LEGACY=false; else LEGACY=true; fi && \
		git clone ${GAFFER_GIT_REPO} /tmp/gaffer && \
		cd /tmp/gaffer && \
		git checkout ${GAFFER_VERSION} || git checkout gaffer2-${GAFFER_VERSION} && \
		for dir in library/*; do if [ -f "${dir}/pom.xml" ]; then echo "${dir}"; fi done | \
		paste -sd, | \
		xargs mvn clean package -Dlegacy=$LEGACY -q -Pquick --also-make -pl store-implementation/accumulo-store/ -pl && \
		if [ ! -f "/jars/accumulo-store-${GAFFER_VERSION}-iterators.jar" ]; then \
			cp ./store-implementation/accumulo-store/target/accumulo-store-*-iterators*.jar /jars; \
		fi && \
		for lib in $(echo ${GAFFER_LIBS} | tr , ' '); do \
			if [ ! -f "/jars/${lib}-${GAFFER_VERSION}-deploy.jar" ]; then \
				cp ./library/${lib}/target/${lib}-*-deploy.jar /jars; \
			fi \
		done \
	fi

FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}
COPY --from=builder --chown=root:root /jars/*.jar /opt/accumulo/lib/ext/
