
GAFFER_VERSION=0.3.9

JACKSON=com/fasterxml/jackson

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

SCHEMA_FILES=\
	example-rest/target/classes/schema/dataSchema.json \
	example-rest/target/classes/schema/dataTypes.json \
	example-rest/target/classes/schema/storeSchema.json \
	example-rest/target/classes/schema/storeTypes.json

PROP_FILES= \
	example-rest/target/classes/mockaccumulostore.properties

all: build gaffer

product:
	mkdir product

build: product
	sudo docker build ${BUILD_ARGS} -t gaffer-dev -f Dockerfile.dev .
	sudo docker build ${BUILD_ARGS} -t gaffer-build -f Dockerfile.build .
	id=$$(sudo docker run -d gaffer-build sleep 3600); \
	dir=/root/.m2/repository; \
	for file in ${WAR_FILES} ${JAR_FILES}; do \
		bn=$$(basename $$file); \
		sudo docker cp $${id}:$${dir}/$${file} product/$${bn}; \
	done; \
	dir=/usr/local/src/gaffer; \
	for file in ${SCHEMA_FILES} ${PROP_FILES}; do \
		bn=$$(basename $$file); \
		sudo docker cp $${id}:$${dir}/$${file} product/$${bn}; \
	done; \
	sudo docker rm -f $${id}

gaffer:
	sudo docker build ${BUILD_ARGS} -t gaffer -f Dockerfile.deploy .

