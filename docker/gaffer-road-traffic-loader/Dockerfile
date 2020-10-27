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

ARG BUILDER_IMAGE_NAME=maven
ARG BUILDER_IMAGE_TAG=3.6.3-jdk-8

ARG BASE_IMAGE_NAME=openjdk
ARG BASE_IMAGE_TAG=8u242-jre-slim-buster

FROM ${BUILDER_IMAGE_NAME}:${BUILDER_IMAGE_TAG} as builder

ARG GAFFER_VERSION=1.13.4
ARG GAFFER_GIT_REPO=https://github.com/gchq/Gaffer.git
ARG GAFFER_DOWNLOAD_URL=https://repo1.maven.org/maven2

WORKDIR /gaffer

# Allow users to provide their own JARs, config and data files
COPY ./files/ .
# Try to download required version of files from Maven Central and GitHub, otherwise build from source
RUN	allFilesDownloaded="TRUE" && \
	if [ ! -f "./road-traffic-generators-${GAFFER_VERSION}-utility.jar" ]; then \
		curl -fLO "${GAFFER_DOWNLOAD_URL}/uk/gov/gchq/gaffer/road-traffic-generators/${GAFFER_VERSION}/road-traffic-generators-${GAFFER_VERSION}-utility.jar" || allFilesDownloaded="FALSE"; \
	fi && \
	if [ ! -f "./accumulo-store-${GAFFER_VERSION}-utility.jar" ]; then \
		curl -fLO "${GAFFER_DOWNLOAD_URL}/uk/gov/gchq/gaffer/accumulo-store/${GAFFER_VERSION}/accumulo-store-${GAFFER_VERSION}-utility.jar" || allFilesDownloaded="FALSE"; \
	fi && \
	if [ ! -f "./roadTrafficSampleData.csv" ]; then \
		curl -fLO https://raw.githubusercontent.com/gchq/Gaffer/gaffer2-${GAFFER_VERSION}/example/road-traffic/road-traffic-demo/src/main/resources/roadTrafficSampleData.csv || \
		curl -fLO https://raw.githubusercontent.com/gchq/Gaffer/${GAFFER_VERSION}/example/road-traffic/road-traffic-demo/src/main/resources/roadTrafficSampleData.csv; \
	fi && \
	if [ ! -f "./graph/graphConfig.json" ]; then \
		mkdir -p graph; \
		curl -fLo graph/graphConfig.json https://raw.githubusercontent.com/gchq/Gaffer/gaffer2-${GAFFER_VERSION}/example/road-traffic/road-traffic-demo/src/main/resources/graphConfig.json || \
		curl -fLo graph/graphConfig.json https://raw.githubusercontent.com/gchq/Gaffer/${GAFFER_VERSION}/example/road-traffic/road-traffic-demo/src/main/resources/graphConfig.json; \
	fi && \
	if [ -z "$(ls ./schema/*.json)" ]; then \
		mkdir -p schema; \
		curl -fLo schema/elements.json https://raw.githubusercontent.com/gchq/Gaffer/gaffer2-${GAFFER_VERSION}/example/road-traffic/road-traffic-model/src/main/resources/schema/elements.json || \
		curl -fLo schema/elements.json https://raw.githubusercontent.com/gchq/Gaffer/${GAFFER_VERSION}/example/road-traffic/road-traffic-model/src/main/resources/schema/elements.json; \
		curl -fLo schema/types.json https://raw.githubusercontent.com/gchq/Gaffer/gaffer2-${GAFFER_VERSION}/example/road-traffic/road-traffic-model/src/main/resources/schema/types.json || \
		curl -fLo schema/types.json https://raw.githubusercontent.com/gchq/Gaffer/${GAFFER_VERSION}/example/road-traffic/road-traffic-model/src/main/resources/schema/types.json; \
	fi && \
	if [ ! -f "./log4j.xml" ]; then \
		curl -fLO https://raw.githubusercontent.com/gchq/Gaffer/gaffer2-${GAFFER_VERSION}/example/road-traffic/road-traffic-demo/src/main/resources/log4j.xml || \
		curl -fLO https://raw.githubusercontent.com/gchq/Gaffer/${GAFFER_VERSION}/example/road-traffic/road-traffic-demo/src/main/resources/log4j.xml; \
	fi && \
	if [ "${allFilesDownloaded}" = "FALSE" ]; then \
		git clone ${GAFFER_GIT_REPO} /tmp/gaffer && \
		pushd /tmp/gaffer && \
		git checkout ${GAFFER_VERSION} && \
		mvn clean package -Pquick --also-make -pl example/road-traffic/road-traffic-generators && \
		if [ ! -f "./road-traffic-generators-${GAFFER_VERSION}-utility.jar" ]; then \
			cp ./example/road-traffic/road-traffic-generators/target/road-traffic-generators-*-utility.jar /gaffer/; \
		fi && \
		if [ ! -f "./accumulo-store-${GAFFER_VERSION}-utility.jar" ]; then \
			cp ./store-implementation/accumulo-store/target/accumulo-store-*-utility.jar /gaffer/; \
		fi && \
		popd; \
	fi

FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}
WORKDIR /gaffer
COPY --from=builder /gaffer /gaffer
ENTRYPOINT [ "java", "-cp", "/gaffer/:/gaffer/*", "uk.gov.gchq.gaffer.traffic.generator.RoadTrafficDataLoader" ]
CMD [ "/gaffer/graph/graphConfig.json", "/gaffer/schema/", "/gaffer/store/store.properties", "/gaffer/roadTrafficSampleData.csv" ]
