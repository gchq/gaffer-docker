# Copyright 2023-2024 Crown Copyright
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

ARG BASE_IMAGE_NAME=gchq/gaffer
ARG BASE_IMAGE_TAG=2.3.0

ARG USER=accumulo
ARG GROUP=accumulo

FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

ENV DEBIAN_FRONTEND=noninteractive

USER root
RUN apt-get -qq update && \
    apt-get -qq install -y krb5-kdc && \
    apt-get -qq clean && \
    rm -rf /var/lib/apt/lists/*
USER ${USER}

COPY ./krb-entrypoint.sh /
ENTRYPOINT ["/krb-entrypoint.sh", "accumulo"]
