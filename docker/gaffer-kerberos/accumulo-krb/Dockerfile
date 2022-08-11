# Copyright 2022 Crown Copyright
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

ARG BASE_IMAGE_NAME=gchq/accumulo
ARG BASE_IMAGE_TAG=1.9.3

ARG USER=accumulo
ARG GROUP=accumulo

FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

USER root
RUN apt -qq update && \
	apt -qq install -y \
		krb5-user && \
    apt -qq clean \
	&& rm -rf /var/lib/apt/lists/*

RUN mkdir /etc/accumulo && \
    chown -R ${USER}:${GROUP} /etc/accumulo

COPY ./krb-entrypoint.sh /
ENTRYPOINT ["/krb-entrypoint.sh", "accumulo"]

USER ${USER}