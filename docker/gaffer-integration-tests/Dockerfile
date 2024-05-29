# Copyright 2021-2023 Crown Copyright
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
ARG BUILDER_IMAGE_TAG=3.9-eclipse-temurin-8

FROM ${BUILDER_IMAGE_NAME}:${BUILDER_IMAGE_TAG}
ARG GAFFER_GIT_REPO=https://github.com/gchq/Gaffer.git
ARG GAFFER_VERSION=develop
ARG ACCUMULO_VERSION=1.9.3
ENV ACCUMULO_VERSION=$ACCUMULO_VERSION
WORKDIR /tests
RUN git clone ${GAFFER_GIT_REPO} /tmp/gaffer && \
	cd /tmp/gaffer && \
	git checkout ${GAFFER_VERSION} || git checkout gaffer2-${GAFFER_VERSION}
COPY ./entrypoint.sh .
COPY ./conf ./conf
RUN chmod +x entrypoint.sh
ENTRYPOINT ["/bin/bash","./entrypoint.sh"]
