ARG BUILDER_IMAGE_NAME=maven
ARG BUILDER_IMAGE_TAG=3.8.4-jdk-8

ARG BASE_IMAGE_NAME=debian
ARG BASE_IMAGE_TAG=stretch-20220125-slim

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

RUN groupadd ${GROUP} && useradd --home /gaffer --gid ${GROUP} --shell /bin/bash ${USER} && \
    mkdir /gaffer && \
    chown -R ${USER}:${GROUP} /gaffer


# TODO - Instead of creating this image from scratch, this could be based on the existing alpine image, which has no easy way to install krb5-user
RUN apt -qq update && \
	apt -qq install -y \
        openjdk-8-jdk-headless \
		krb5-user && \
	apt -qq clean \
	&& rm -rf /var/lib/apt/lists/*

USER ${USER}:${GROUP}

COPY --chown=${USER}:${GROUP} /config /gaffer
COPY --chown=${USER}:${GROUP} --from=builder /jars /gaffer/jars
COPY --chown=${USER}:${GROUP} ./krb-entrypoint.sh /

WORKDIR /gaffer
ENTRYPOINT ["/krb-entrypoint.sh"]
