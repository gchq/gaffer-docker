
ARG BUILDER_IMAGE_NAME=maven
ARG BUILDER_IMAGE_TAG=3.6.3-jdk-8

ARG BASE_IMAGE_NAME=jboss/wildfly
ARG BASE_IMAGE_TAG=10.1.0.Final

FROM ${BUILDER_IMAGE_NAME}:${BUILDER_IMAGE_TAG} as builder

ARG GAFFER_VERSION=1.11.0
ARG GAFFER_TOOLS_VERSION=${GAFFER_VERSION}
ARG GAFFER_GIT_REPO=https://github.com/gchq/Gaffer.git
ARG GAFFER_TOOLS_GIT_REPO=https://github.com/gchq/gaffer-tools.git
ARG GAFFER_DOWNLOAD_URL=https://repo1.maven.org/maven2

WORKDIR /wars

# Allow users to provide their own WAR files - should be called rest.war and ui.war
COPY ./wars/ .
# Try to download required version from Maven Central, otherwise build from source
RUN	if [ ! -f "./rest.war" ]; then \
		curl -fLo rest.war "${GAFFER_DOWNLOAD_URL}/uk/gov/gchq/gaffer/accumulo-rest/${GAFFER_VERSION}/accumulo-rest-${GAFFER_VERSION}.war" || true; \
	fi && \
	if [ ! -f "./ui.war" ]; then \
		curl -fLo ui.war "${GAFFER_DOWNLOAD_URL}/uk/gov/gchq/gaffer/ui/${GAFFER_TOOLS_VERSION}/ui-${GAFFER_TOOLS_VERSION}.war" || true; \
	fi && \
	if [ ! -f "./rest.war" ]; then \
		git clone ${GAFFER_GIT_REPO} /tmp/gaffer && \
		cd /tmp/gaffer && \
		git checkout ${GAFFER_VERSION} && \
		mvn clean package -Pquick --also-make -pl rest-api/accumulo-rest && \
		cp ./rest-api/accumulo-rest/target/accumulo-rest-*.war /wars/ && \
		cd /wars/; \
	fi && \
	if [ ! -f "./ui.war" ]; then \
		git clone ${GAFFER_TOOLS_GIT_REPO} /tmp/gaffer-tools && \
		cd /tmp/gaffer-tools && \
		git checkout ${GAFFER_TOOLS_VERSION} && \
		mvn clean package -Pquick --also-make -pl ui && \
		cp ./ui/target/ui-*.war /wars/ && \
		cd /wars/; \
	fi

FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}
COPY --from=builder --chown=jboss /wars/*.war /opt/jboss/wildfly/standalone/deployments/
COPY --chown=jboss ./config /gaffer
CMD [ "/opt/jboss/wildfly/bin/standalone.sh", "-b", "0.0.0.0", "-Dgaffer.schemas=/gaffer/schema", "-Dgaffer.storeProperties=/gaffer/store.properties", "-Dgaffer.graph.config=/gaffer/graphConfig.json" ]
