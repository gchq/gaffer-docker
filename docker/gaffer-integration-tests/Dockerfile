ARG BUILDER_IMAGE_NAME=maven
ARG BUILDER_IMAGE_TAG=3.6.3-jdk-8

ARG BASE_IMAGE_NAME=openjdk
ARG BASE_IMAGE_TAG=8u242-jre-slim-buster

FROM ${BUILDER_IMAGE_NAME}:${BUILDER_IMAGE_TAG} as builder
ARG GAFFER_GIT_REPO=https://github.com/gchq/Gaffer.git
ARG GAFFER_VERSION=1.13.4
COPY ./docker-entrypoint.sh / && \
     cp ./conf/ /
RUN chmod +x docker-entrypoint.sh \
    git clone ${GAFFER_GIT_REPO} /tmp/gaffer && \
	cd /tmp/gaffer && \
	git checkout ${GAFFER_VERSION}
ENTRYPOINT ["/bin/bash","./docker-entrypoint.sh"]