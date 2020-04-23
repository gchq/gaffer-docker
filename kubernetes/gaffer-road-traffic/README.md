# Gaffer Road Traffic Helm Chart

This Helm Chart can be used to deploy a Gaffer instance, containing sample GB road traffic data from the Department of Transport, onto a Kubernetes cluster.

By default, this chart deploys:
* a ZooKeeper instance, running in standalone mode
* a HDFS instance:
  * configured with a replication factor of 3
  * name node configured with 1 x 10GB data volume
  * 3 x data nodes, each configured with 2 x 10GB data volumes
* an Accumulo instance:
  * master, monitor, garbage collector
  * 3 x tablet servers
* a web server running the Gaffer REST API and UI
* a Gaffer graph configured with the [Road Traffic Counts Schema](https://github.com/gchq/Gaffer/tree/master/example/road-traffic/road-traffic-model/src/main/resources/schema)


## Deployment

There are guides for deploying this chart on:
* a local Kubernetes cluster, [using kind (Kubernetes IN Docker)](docs/kind-deployment.md)
* an [AWS EKS cluster](docs/aws-eks-deployment.md)
