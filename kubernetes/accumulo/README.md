Accumulo Helm Chart
==================================

This Helm Chart deploys Accumulo onto a Kubernetes cluster.

By default this chart deploys:
* a ZooKeeper instance
* a HDFS instance:
* an Accumulo instance:
  * master, monitor, garbage collector
  * 3 x tablet servers


# Deployment
There are guides for deploying this chart on, they should be read in the following order:
* [Provision and configure a local Kubernetes cluster](../docs/kind-deployment.md)
* [Deploy Accumulo on a Kubernetes cluster](./docs/kind-deployment.md)
