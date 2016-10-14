##########################################################
# Copyright 2016 Crown Copyright, cybermaggedon
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
##########################################################

GAFFER_VERSION=0.4.4

REPOSITORY=docker.io/gchq/gaffer

WAR_FILES=\
	gaffer/example-rest/${GAFFER_VERSION}/example-rest-${GAFFER_VERSION}.war \
	gaffer/ui/${GAFFER_VERSION}/ui-${GAFFER_VERSION}.war

JAR_FILES=\
	gaffer/accumulo-store/${GAFFER_VERSION}/accumulo-store-${GAFFER_VERSION}-iterators.jar \
	gaffer/common-util/${GAFFER_VERSION}/common-util-${GAFFER_VERSION}.jar \
	gaffer/simple-function-library/${GAFFER_VERSION}/simple-function-library-${GAFFER_VERSION}-shaded.jar \
	gaffer/simple-serialisation-library/${GAFFER_VERSION}/simple-serialisation-library-${GAFFER_VERSION}-shaded.jar \

VERSION=${GAFFER_VERSION}

SUDO=

PROXY_ARGS=--build-arg HTTP_PROXY=${http_proxy} --build-arg http_proxy=${http_proxy} --build-arg HTTPS_PROXY=${https_proxy} --build-arg https_proxy=${https_proxy}

PROXY_HOST_PORT_ARGS=--build-arg proxy_host=${proxy_host} --build-arg proxy_host=${proxy_host} --build-arg proxy_port=${proxy_port}

all: build container

product:
	mkdir product

# In the future this could be removed when the Gaffer binaries are published to Maven Central.
build: product
	${SUDO} docker build ${PROXY_ARGS} ${PROXY_HOST_PORT_ARGS} ${BUILD_ARGS} --build-arg GAFFER_VERSION=${GAFFER_VERSION} -t gaffer-build -f Dockerfile.build .
	id=$$(${SUDO} docker run -d gaffer-build sleep 3600); \
	dir=/root/.m2/repository; \
	for file in ${WAR_FILES} ${JAR_FILES}; do \
		bn=$$(basename $$file); \
		${SUDO} docker cp $${id}:$${dir}/$${file} product/$${bn}; \
	done; \
	${SUDO} docker rm -f $${id}

container: wildfly-10.1.0.CR1.zip
	${SUDO} docker build ${PROXY_ARGS} ${BUILD_ARGS} -t gaffer -f Dockerfile.deploy .
	${SUDO} docker tag gaffer ${REPOSITORY}:${VERSION}

wildfly-10.1.0.CR1.zip:
	wget download.jboss.org/wildfly/10.1.0.CR1/wildfly-10.1.0.CR1.zip

push:
	${SUDO} docker push ${REPOSITORY}:${VERSION}

