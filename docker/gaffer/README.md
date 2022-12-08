Gaffer
======
In this folder you can find the required files for building and running Gaffer Accumulo and Gaffer in Docker containers.

The Docker image uses the Gaffer Accumulo image with the Gaffer iterators added in.
When run with docker-compose it will provide you a full accumulo ecosystem complete with [hdfs](../hdfs), [Gaffer REST API](../gaffer-rest), and also the Gaffer UI.

# Running Locally
The easiest way to build and run these services is to use docker-compose, by running the following from this directory:
```bash
docker-compose up
```

## Customising the build
To add your own libraries into the build, you can add files to the /files directory these will automatically be added to 
accumulo's /opt/accumulo/lib/ext directory when you bring the containers up.

## Containers that are started:
* Zookeeper
* HDFS
* Accumulo
* Gaffer REST
* Gaffer UI

Access the HDFS NameNode web UI at: http://localhost:9870
Access the Accumulo Monitor UI at: http://localhost:9995
Access the Gaffer Web UI at: http://localhost:5000/ui/
Access the Gaffer REST API at: http://localhost:8080/rest/
