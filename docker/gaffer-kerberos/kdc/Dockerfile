# Copyright 2022-2024 Crown Copyright
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

ARG BASE_IMAGE_NAME=ubuntu
ARG BASE_IMAGE_TAG=noble-20240429

FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get -qq update && \
    apt-get -qq install -y \
        krb5-kdc krb5-admin-server \
        procps && \
    apt-get -qq clean && \
    rm -rf /var/lib/apt/lists/*

COPY ./entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
