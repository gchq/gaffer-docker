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

ARG BASE_IMAGE_NAME=jboss/wildfly
ARG BASE_IMAGE_TAG=10.1.0.Final

FROM ${BUILDER_IMAGE_NAME}:${BUILDER_IMAGE_TAG} as builder

ARG GAFFER_TOOLS_VERSION=allow-custom-endpoint-path
ARG GAFFER_TOOLS_GIT_REPO=https://github.com/gchq/gaffer-tools.git
ARG GAFFER_DOWNLOAD_URL=https://repo1.maven.org/maven2

WORKDIR /wars

# Allow users to provide their own WAR files - should be called ui.war
COPY ./wars/ .
# Try to download required version from Maven Central, otherwise build from source
RUN	if [ ! -f "./ui.war" ]; then \
		curl -sfLo ui.war "${GAFFER_DOWNLOAD_URL}/uk/gov/gchq/gaffer/ui/${GAFFER_TOOLS_VERSION}/ui-${GAFFER_TOOLS_VERSION}.war" || true; \
	fi && \
	if [ ! -f "./ui.war" ]; then \
		git clone ${GAFFER_TOOLS_GIT_REPO} /tmp/gaffer-tools && \
		cd /tmp/gaffer-tools && \
		git checkout ${GAFFER_TOOLS_VERSION} && \
		mvn clean package -q -Pquick --also-make -pl ui && \
		cp ./ui/target/ui-*.war /wars/ui.war && \
		cd /wars/; \
	fi && \
	mv ./ui.war ./ui.orig.war && \
	mkdir -p /wars/ui.war/ && \
	touch /wars/ui.war.dodeploy && \
	cd /wars/ui.war/ && \
	mv ../ui.orig.war . && \
	jar -xf ./ui.orig.war && \
	rm ./ui.orig.war && \
	apt update && \
	apt install -y xmlstarlet && \
	rm -rf /var/lib/apt/lists/* && \
	xmlstarlet ed --inplace -s "/jboss-web" -t elem -n "symbolic-linking-enabled" -v "true" ./WEB-INF/jboss-web.xml;

FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}
COPY --from=builder --chown=jboss /wars/ /opt/jboss/wildfly/standalone/deployments/
CMD [ "/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0" ]
