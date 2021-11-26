Gaffer Helm Chart
==========================

Gaffer is a graph database framework. It allows the storage of very large graphs containing rich properties on the nodes and edges. This Helm Chart can be used to deploy a Gaffer instance, using Accumulo as its store, onto a Kubernetes cluster.

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
* a Gaffer graph configured with a [basic simple schema](config/schema/)


## Deployment

There are guides for deploying this chart on:
* a local Kubernetes cluster, [using kind (Kubernetes IN Docker)](docs/kind-deployment.md)
* an [AWS EKS cluster](docs/aws-eks-deployment.md)
