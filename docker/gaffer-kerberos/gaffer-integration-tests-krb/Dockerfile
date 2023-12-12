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

ARG GAFFER_VERSION=develop
ARG ACCUMULO_VERSION=1.9.3

ARG BASE_IMAGE_NAME=gchq/gaffer-integration-tests
ARG BASE_IMAGE_TAG=${GAFFER_VERSION}-accumulo-${ACCUMULO_VERSION}

FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

RUN DEBIAN_FRONTEND=noninteractive apt-get -qq update && \
	DEBIAN_FRONTEND=noninteractive apt-get -qq install -y \
		krb5-kdc && \
    apt-get -qq clean \
    && rm -rf /var/lib/apt/lists/*

COPY ./native /tmp/hadoop/native
COPY ./krb-entrypoint.sh .
ENTRYPOINT ["/bin/bash","./krb-entrypoint.sh"]