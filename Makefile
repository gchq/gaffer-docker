
GAFFER_VERSION=0.3.9

JACKSON=com/fasterxml/jackson

REPOSITORY=docker.io/cybermaggedon/gaffer

WAR_FILES=\
	gaffer/example-rest/${GAFFER_VERSION}/example-rest-${GAFFER_VERSION}.war

JAR_FILES=\
	gaffer/accumulo-store/${GAFFER_VERSION}/accumulo-store-${GAFFER_VERSION}-iterators.jar \
	gaffer/simple-function-library/${GAFFER_VERSION}/simple-function-library-${GAFFER_VERSION}.jar \
	gaffer/simple-serialisation-library/${GAFFER_VERSION}/simple-serialisation-library-${GAFFER_VERSION}.jar \
	${JACKSON}/core/jackson-annotations/2.6.2/jackson-annotations-2.6.2.jar \
	${JACKSON}/core/jackson-core/2.6.2/jackson-core-2.6.2.jar \
	${JACKSON}/core/jackson-databind/2.6.2/jackson-databind-2.6.2.jar \
	${JACKSON}/datatype/jackson-datatype-json-org/2.3.3/jackson-datatype-json-org-2.3.3.jar \
	${JACKSON}/jaxrs/jackson-jaxrs-base/2.6.2/jackson-jaxrs-base-2.6.2.jar \
	${JACKSON}/jaxrs/jackson-jaxrs-json-provider/2.6.2/jackson-jaxrs-json-provider-2.6.2.jar \
	${JACKSON}/module/jackson-module-jaxb-annotations/2.6.2/jackson-module-jaxb-annotations-2.6.2.jar \
	${JACKSON}/module/jackson-module-jsonSchema/2.1.0/jackson-module-jsonSchema-2.1.0.jar \
	${JACKSON}/module/jackson-module-scala_2.10/2.1.5/jackson-module-scala_2.10-2.1.5.jar

SUDO=

SCHEMA_FILES=\
	example-rest/target/classes/schema/dataSchema.json \
	example-rest/target/classes/schema/dataTypes.json \
	example-rest/target/classes/schema/storeSchema.json \
	example-rest/target/classes/schema/storeTypes.json

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
	dir=/usr/local/src/gaffer; \
	for file in ${SCHEMA_FILES} ${PROP_FILES}; do \
		bn=$$(basename $$file); \
		${SUDO} docker cp $${id}:$${dir}/$${file} product/$${bn}; \
	done; \
	${SUDO} docker rm -f $${id}

VERSION=${GAFFER_VERSION}

container: wildfly-10.1.0.CR1.zip
	${SUDO} docker build ${BUILD_ARGS} -t gaffer -f Dockerfile.deploy .
	${SUDO} docker tag gaffer ${REPOSITORY}:${VERSION}

wildfly-10.1.0-CR1.zip:
	wget download.jboss.org/wildfly/10.1.0.CR1/wildfly-10.1.0.CR1.zip

push:
	${SUDO} docker push ${REPOSITORY}:${VERSION}

