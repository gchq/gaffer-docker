# Copyright 2023 Crown Copyright
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

ARG BASE_IMAGE_NAME=zookeeper
ARG BASE_IMAGE_TAG=3.7.1

FROM ${BASE_IMAGE_NAME}:${BASE_IMAGE_TAG}

RUN DEBIAN_FRONTEND=noninteractive apt-get -qq update && \
	DEBIAN_FRONTEND=noninteractive apt-get -qq install -y \
		krb5-usr && \
    apt-get -qq clean \
    && rm -rf /var/lib/apt/lists/*

COPY ./krb-entrypoint.sh /
ENTRYPOINT ["/krb-entrypoint.sh"]
CMD ["zkServer.sh", "start-foreground"]
