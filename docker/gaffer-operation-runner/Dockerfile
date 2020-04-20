ARG BUILDER_IMAGE_NAME=maven
ARG BUILDER_IMAGE_TAG=3.6.3-jdk-8

ARG BASE_IMAGE_NAME=gchq/gaffer
ARG BASE_IMAGE_TAG=1.11.0

FROM ${BUILDER_IMAGE_NAME}:${BUILDER_IMAGE_TAG} as builder

COPY ./operation-runner/ /operation-runner/
WORKDIR /gaffer
COPY ./files/ .
RUN if [ ! -f "jars/operation-runner-*.jar" ]; then \
        cd /operation-runner/ && \
        mvn -q clean package && \
        cp target/operation-runner-*-with-dependencies.jar ${OLDPWD}/jars/ && \
        cd ${OLDPWD}; \
    fi
FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

WORKDIR /gaffer
COPY --from=builder /gaffer/ .
COPY entrypoint.sh /
ENTRYPOINT [ "/entrypoint.sh" ]
