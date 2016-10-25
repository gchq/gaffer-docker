
GAFFER_VERSION=0.4.4
ACCUMULO_REPOSITORY=cybermaggedon/accumulo-gaffer
WILDFLY_REPOSITORY=cybermaggedon/wildfly-gaffer

JACKSON=com/fasterxml/jackson

REPOSITORY=docker.io/gchq/gaffer

WAR_FILES=\
	gaffer/example-rest/${GAFFER_VERSION}/example-rest-${GAFFER_VERSION}.war \
        gaffer/ui/${GAFFER_VERSION}/ui-${GAFFER_VERSION}.war

JAR_FILES=\
        gaffer/accumulo-store/${GAFFER_VERSION}/accumulo-store-${GAFFER_VERSION}-iterators.jar \
        gaffer/common-util/${GAFFER_VERSION}/common-util-${GAFFER_VERSION}.jar \
        gaffer/simple-function-library/${GAFFER_VERSION}/simple-function-library-${GAFFER_VERSION}-shaded.jar \
        gaffer/simple-serialisation-library/${GAFFER_VERSION}/simple-serialisation-library-${GAFFER_VERSION}-shaded.jar \

SUDO=

PROP_FILES= \
	example-rest/target/classes/mockaccumulostore.properties

all: build container

product:
	mkdir product

build: product
	${SUDO} docker build ${BUILD_ARGS} -t gaffer-dev -f Dockerfile.dev .
	${SUDO} docker build ${BUILD_ARGS} -t gaffer-build -f Dockerfile.build .
	id=$$(${SUDO} docker run -d gaffer-build sleep 3600); \
	dir=/root/.m2/repository; \
	for file in ${WAR_FILES} ${JAR_FILES}; do \
		bn=$$(basename $$file); \
		${SUDO} docker cp $${id}:$${dir}/$${file} product/$${bn}; \
	done; \
	${SUDO} docker rm -f $${id}

VERSION=${GAFFER_VERSION}

container: wildfly-10.1.0.CR1.zip
	${SUDO} docker build ${BUILD_ARGS} -t ${ACCUMULO_REPOSITORY}:${VERSION} -f Dockerfile.accumulo .
	${SUDO} docker build ${BUILD_ARGS} -t ${WILDFLY_REPOSITORY}:${VERSION} -f Dockerfile.wildfly .

wildfly-10.1.0.CR1.zip:
	wget download.jboss.org/wildfly/10.1.0.CR1/wildfly-10.1.0.CR1.zip

push:
	${SUDO} docker push ${REPOSITORY}:${VERSION}

