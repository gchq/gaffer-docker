Gaffer Operation Runner
========================
In this folder you can find the required files for running a Gaffer operation directly on the Gaffer instance (bypassing the REST service).

The operation that is executed must be specified in the files/operation/operation.json file.
By default, the runner counts all the elements in the graph.

## Source code
The Operation Runner runs a Java program, the source code for which is located in the operation-runner directory.

To overwrite the Jar used to run an operation, place the jar in 'files/jars'.

## Custom Jars
To add Custom Jars to your deployment, add them to the files/jars directory. They will automatically get added to the classpath when the operation is run.
You will then need to rebuild the container for the changes to take effect.

## Deployment

To deploy the Road Traffic Dataset and run the operation, use:

```bash
docker-compose up
```

To run the operation as a standalone, use:
```bash
docker-compose up operation-runner
```

And to re-run the operation after changing it, use:
```bash
docker-compose up --build operation-runner
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