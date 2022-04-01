ARG BUILDER_IMAGE_NAME=maven
ARG BUILDER_IMAGE_TAG=3.8.4-jdk-8

ARG BASE_IMAGE_NAME=openjdk
ARG BASE_IMAGE_TAG=8-jre-alpine

FROM ${BUILDER_IMAGE_NAME}:${BUILDER_IMAGE_TAG} as builder

ARG GAFFER_VERSION=2.0.0-alpha-0.1
ARG GAFFER_GIT_REPO=https://github.com/gchq/Gaffer.git
ARG GAFFER_DOWNLOAD_URL=https://repo1.maven.org/maven2

WORKDIR /jars

# Allow users to provide their own Runnable Jar files - should be called rest.jar
# If users want to provide their own utility jars they can do that within jars/lib
COPY ./jars/ .

RUN	if [ ! -f "./rest.jar" ]; then \
		curl -sfLo rest.jar "${GAFFER_DOWNLOAD_URL}/uk/gov/gchq/gaffer/spring-rest/${GAFFER_VERSION}/spring-rest-${GAFFER_VERSION}-exec.jar" || true; \
	fi && \
    if [ ! -f "./rest.jar" ]; then \
		git clone ${GAFFER_GIT_REPO} /tmp/gaffer && \
		cd /tmp/gaffer && \
		git checkout ${GAFFER_VERSION} && \
		mvn clean package -q -Pquick --also-make -pl :spring-rest && \
		cp ./rest-api/spring-rest/target/spring-rest-*-exec.jar /jars/rest.jar && \
		cd /jars/; \
	fi

FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}
ARG GROUP=gaffer
ARG USER=gaffer

RUN addgroup ${GROUP} && adduser -h /gaffer -G ${GROUP} -H -D ${USER}

USER ${USER}:${GROUP}

COPY /config /gaffer
COPY --from=builder /jars /gaffer/jars

WORKDIR /gaffer
ENTRYPOINT ["java", "-Dloader.path=/gaffer/jars/lib", "-jar", "jars/rest.jar" ]