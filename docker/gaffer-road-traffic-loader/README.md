Gaffer Road Traffic Example
===========================

In this folder you can find the required files for building and running the Gaffer Road Traffic example inside of Docker containers.

# Running Locally
The easiest way to build and run these services is to use docker compose, by running the following from this directory:
```bash
docker compose up
```

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
* Gaffer REST
* Gaffer UI

Access the HDFS NameNode web UI at: http://localhost:9870

Access the Accumulo Monitor UI at: http://localhost:9995

Access the Gaffer Web UI at: http://localhost:5000/ui/

Access the Gaffer REST API at: http://localhost:8080/rest/

Access the HDFS NameNode web UI at: http://localhost:9870
