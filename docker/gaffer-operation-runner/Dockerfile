ARG BUILDER_IMAGE_NAME=maven
ARG BUILDER_IMAGE_TAG=3.6.3-jdk-8

ARG BASE_IMAGE_NAME=gchq/gaffer
ARG BASE_IMAGE_TAG=1.11.0

FROM ${BUILDER_IMAGE_NAME}:${BUILDER_IMAGE_TAG} as builder

WORKDIR /operation-runner
COPY ./operation-runner/ .
RUN mvn -q clean package

WORKDIR /gaffer
COPY ./files/ .
RUN cp /operation-runner/target/operation-runner-1.0-SNAPSHOT-with-dependencies.jar /gaffer/jars/ 

FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

WORKDIR /gaffer
COPY --from=builder /gaffer/ .
COPY entrypoint.sh .
ENTRYPOINT [ "./entrypoint.sh" ]
