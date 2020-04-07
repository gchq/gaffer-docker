# Deploying HDFS using kind

First follow the [instructions here](../../kind-deployment.md) to provision and configure a local Kubernetes cluster, using [kind](https://kind.sigs.k8s.io/) (Kubernetes IN Docker), that the HDFS Helm Chart can be deployed on.

```
export HADOOP_VERSION=${HADOOP_VERSION:-3.2.1}

helm install hdfs . \
  --set hdfs.namenode.tag=${HADOOP_VERSION} \
  --set hdfs.datanode.tag=${HADOOP_VERSION} \
  --set hdfs.shell.tag=${HADOOP_VERSION}

helm test hdfs
```
