Gaffer Federated Integration Tests
=========================
In this folder there is a docker compose file for running the Gaffer Integration Tests, but with a modified config to test the FederatedStore.  
Instead of directly using one AccumuloStore, it uses a FederatedStore which proxies to another FederatedStore which has two AccumuloStores within it.  
This is useful for testing multiple store types at once, as well as interactions between different Gaffer versions federating between each other.  
For more info see [conf/tester/PublicAccessPredefinedFederatedStore.java](conf/tester/PublicAccessPredefinedFederatedStore.java).  

# Running Locally
The easiest way to build and run these services is to use docker compose, by running the following from this directory:
```bash
docker compose up
```

## Customising the build
You can customise the store properties that will get used by the tests by providing some at `/tests/conf/tester/store.properties`.  
If you are using the docker compose, these can be found in [conf/tester/store.properties](conf/tester/store.properties).

Additionally, you can change the various versions with the following environment variables (found in [.env](.env)):
- Hadoop: `HADOOP_VERSION`
- Accumulo: `ACCUMULO_VERSION`
- Gaffer iterators within Accumulo: `GAFFER_VERSION`
- Inner Gaffer graph containing 2 AccumuloStores within FederatedStore: `GAFFER_VERSION`
- Outer Gaffer graph that runs ITs and has FederatedStore with ProxyStore to the inner graph: `GAFFER_TESTER_VERSION`

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
* Gaffer Rest (FederatedStore->2xAccumuloStore)
* Gaffer FederatedStore ITs (FederatedStore->ProxyStore(Gaffer Rest))

Access the HDFS NameNode web UI at: http://localhost:9870

Access the Accumulo Monitor UI at: http://localhost:9995

Check the integration test logs with: `docker logs gaffer-integration-tests_gaffer-integration-tests_1`
