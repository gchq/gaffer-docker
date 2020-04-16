ARG BUILDER_IMAGE_NAME=maven
ARG BUILDER_IMAGE_TAG=3.6.3-jdk-8

ARG BASE_IMAGE_NAME=gchq/gaffer
ARG BASE_IMAGE_TAG=1.11.0

FROM ${BUILDER_IMAGE_NAME}:${BUILDER_IMAGE_TAG} as builder

WORKDIR /gaffer
COPY ./operation-runner/ .
RUN mvn -q clean package

FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

WORKDIR /operation
COPY operation/operation.json .
COPY --from=builder /gaffer/target/operation-runner-1.0-SNAPSHOT-with-dependencies.jar ./runner.jar
COPY jars/ ./jars
COPY entrypoint.sh .
ENTRYPOINT [ "/operation/entrypoint.sh" ]
