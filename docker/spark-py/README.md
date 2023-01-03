spark-py
=========

In this folder you can find the required files for building and running an executor container image for [Spark's official Kubernetes support](http://spark.apache.org/docs/latest/running-on-kubernetes.html).

This is used by `kubernetes/gaffer-jhub/` but can be built and run independently.

To use this image, update your Spark configuration (e.g. `spark-defaults.conf`) to include:

```
spark.kubernetes.container.image gchq/spark-py:latest
```

# Building Locally
The easiest way to build this service is to use docker-compose, by running the following from this directory:
```bash
docker-compose build
```
## Images that are built:
* Spark

## Running Locally
You can start build and run the container as well, by running the following from this directory:
```bash
docker-compose up
```
The container will stop once it has run through the entrypoint.sh script.


