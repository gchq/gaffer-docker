ARG BUILDER_IMAGE_NAME=maven
ARG BUILDER_IMAGE_TAG=3.8.4-jdk-8

FROM ${BUILDER_IMAGE_NAME}:${BUILDER_IMAGE_TAG}
ARG GAFFER_GIT_REPO=https://github.com/gchq/Gaffer.git
ARG GAFFER_VERSION=develop
WORKDIR /tests
RUN git clone ${GAFFER_GIT_REPO} /tmp/gaffer && \
	cd /tmp/gaffer && \
	git checkout ${GAFFER_VERSION} || git checkout gaffer2-${GAFFER_VERSION}
COPY ./entrypoint.sh .
COPY ./conf ./conf
RUN chmod +x entrypoint.sh
ENTRYPOINT ["/bin/bash","./entrypoint.sh"]