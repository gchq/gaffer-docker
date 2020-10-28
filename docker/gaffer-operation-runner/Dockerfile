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

ARG BASE_IMAGE_NAME=gchq/gaffer
ARG BASE_IMAGE_TAG=1.13.4

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
