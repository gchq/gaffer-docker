Gremlin Gaffer Plugin
======
In this folder you can find the required files for building and running a gremlin-server with the Gaffer plugin loaded.

The Docker image uses TinkerPop's gremlin-server with GafferPop config and plugin jars added in.
When run with docker compose it will provide you a full accumulo ecosystem complete with [hdfs](../hdfs) and the [Gaffer REST API](../gaffer-rest).

# Running Locally
The easiest way to build and run these services is to use docker compose, by running the following from this directory:
```bash
docker compose up
```

## Example Notebook
See `gremlin-gaffer-modern-example.ipynb` for an example using the "TinkerPop Modern" demo graph.

## Customising the build
Custom Gaffer TinkerPop plugin jars can be added in the files directory. The Gaffer schema, store properties and gafferpop properties can be found in `conf/gafferpop` and are customised in a docker compose build using volumes. The `gremlin-server-empty-gaffer.yaml` cannot be overwritten in a volume, it must be built into the image.

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
* Gremlin Server with GafferPop

Access the HDFS NameNode web UI at: http://localhost:9870

Access the Accumulo Monitor UI at: http://localhost:9995

Access the Gaffer REST API at: http://localhost:8080/rest/

Access the Gremlin Server with GafferPop at: http://localhost:8182/
