ARG BUILDER_IMAGE_NAME=maven
ARG BUILDER_IMAGE_TAG=3.6.3-jdk-8


FROM ${BUILDER_IMAGE_NAME}:${BUILDER_IMAGE_TAG} 
ARG GAFFER_GIT_REPO=https://github.com/gchq/Gaffer.git
ARG GAFFER_VERSION=1.15.0
WORKDIR /tests
RUN git clone ${GAFFER_GIT_REPO} /tmp/gaffer && \
    cd /tmp/gaffer && \
    git checkout ${GAFFER_VERSION} 
COPY ./docker-entrypoint.sh . 
COPY ./conf ./conf
RUN chmod +x docker-entrypoint.sh   	
ENTRYPOINT ["/bin/bash","./docker-entrypoint.sh"]