# gafferpy Jupyter Notebook

This extends [scipy-notebook](https://github.com/jupyter/docker-stacks/tree/master/scipy-notebook) to include:

* OpenJDK 11 JRE
* AWS CLI
* Hadoop
* Spark
* `kubectl` and the `kubernetes` python package
* [gafferpy](https://github.com/gchq/gaffer-tools/tree/master/python-shell)

Some example notebooks that demonstrate how to query Gaffer and use Spark are available at [`/examples`](examples/)


## Running on a single node

```
docker-compose up
```

Access the HDFS NameNode web UI at: http://localhost:9870

Access the Accumulo Monitor UI at: http://localhost:9995

Access the Gaffer Web UI at: http://localhost:8080/ui/

Access the Gaffer REST API at: http://localhost:8080/rest/

Access the Jupyter Notebook at: http://localhost:8888


## Running on a Kubernetes cluster

See the [gaffer-jhub Helm Chart](../../kubernetes/gaffer-jhub/)
