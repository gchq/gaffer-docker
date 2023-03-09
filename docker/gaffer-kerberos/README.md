Gaffer with Kerberos
======
This folder contains images which build on those in the parent directory to use Kerberos for authentication.
There's also an extra Dockerfile and image to implement a Kerberos KDC.

### Purpose

These images are for testing purposes only.
They are only to be used for confirming that Gaffer's support for authenticating with Accumulo using Kerberos is working correctly.
Configuration has been simplified as much as possible and is not indicative of how a Kerberos environment should be setup. 

### Kerberos Debugging

To see more Kerberos information in the container logs, set `DEBUG`to `1` in the docker compose `.env` file.

## Building
You can build the images using docker-compose:

```bash
docker-compose build
```

## Running

```
docker-compose up
```

## Containers that are started:
* Kerberos KDC (Key Distribution Center)
* Zookeeper (w/ Kerberos authentication)
* HDFS
    * Datanode (w/ Kerberos authentication)
    * Namenode (w/ Kerberos authentication)
* Accumulo
    * Monitor (w/ Kerberos authentication)
    * GC (w/ Kerberos authentication)
    * tserver (w/ Kerberos authentication)
    * Master (w/ Kerberos authentication)
* Gaffer REST (w/ Kerberos authentication)

Access the HDFS NameNode web UI at: http://localhost:9870

Access the Accumulo Monitor UI at: http://localhost:9995

Access the Gaffer REST API at: http://localhost:8080/rest/