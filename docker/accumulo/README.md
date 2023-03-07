Accumulo
================
In this folder you can find the required files for building and running Apache Accumulo in Docker containers.

Note: this does not bring up an instance of Gaffer.

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

Access the HDFS NameNode web UI at: http://localhost:9870

Access the Accumulo Monitor UI at: http://localhost:9995

## Change Accumulo minor version
To update the Accumulo minor version, not only must all the references to the old version be replaced, but the config
directories must be renamed to the correct version, and their contents checked. For example: `conf-2.0.1` -> `conf-2.1.0`
