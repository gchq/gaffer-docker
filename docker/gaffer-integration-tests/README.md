Gaffer Integration Tests
=========================
In this folder you can find the required Dockerfile for running integration tests against an Accumulo cluster.
This is used by the [Helm scripts](kubernetes/gaffer/templates/tests/integration/accumulo-tests.yaml), as well as the docker-compose file provided.

# Running Locally
The easiest way to build and run these services is to use docker-compose, by running the following from this directory:
```bash
docker-compose up
```

## Customising the build
You can customise the store properties that will get used by the tests by providing some at `/tests/conf/store.properties`.  
If you are using the docker-compose, these can be found in [conf/store.properties](conf/store.properties).

Additionally, you can change the various versions with the following environment variables (found in [.env](.env)):
- Hadoop: `HADOOP_VERSION`
- Accumulo: `ACCUMULO_VERSION`
- Gaffer iterators within Accumulo: `GAFFER_VERSION`
- Gaffer graph that runs ITs: `GAFFER_TESTER_VERSION`

## Containers that are started:
* Zookeeper
* HDFS
    * Datanode
    * Namenode
* Accumulo
    * Monitor
    * GC
    * tserver
    * Master
* Gaffer AccumuloStore ITs

Access the HDFS NameNode web UI at: http://localhost:9870

Access the Accumulo Monitor UI at: http://localhost:9995

Check the integration test logs with: `docker logs gaffer-integration-tests_gaffer-integration-tests_1`
