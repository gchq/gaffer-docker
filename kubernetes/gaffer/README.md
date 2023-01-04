Gaffer Helm Chart
==================

In this directory you can find the Helm charts required to deploy Gaffer onto Kubernetes clusters. 

By default this chart deploys:
* a ZooKeeper instance
* a HDFS instance:
* an Accumulo instance:
  * master, monitor, garbage collector
  * 3 x tablet servers
* a web server running the Gaffer REST API and UI

# Deployment
There are guides for deploying this chart on, they should be read in the following order:
* [Provision and configure a local Kubernetes cluster](../docs/kind-deployment.md)
* [Deploy Gaffer on a Kubernetes cluster](./docs/kind-deployment.md)
