# Deploying Gaffer using kind

First follow the [instructions here](../../kind-deployment.md) to provision and configure a local Kubernetes cluster, using [kind](https://kind.sigs.k8s.io/) (Kubernetes IN Docker), that the Gaffer Helm Chart can be deployed on.

```
export HADOOP_VERSION=${HADOOP_VERSION:-3.2.1}
export GAFFER_VERSION=${GAFFER_VERSION:-1.11.0}

helm dependency update

helm install gaffer . \
  --set hdfs.namenode.tag=${HADOOP_VERSION} \
  --set hdfs.datanode.tag=${HADOOP_VERSION} \
  --set hdfs.shell.tag=${HADOOP_VERSION} \
  --set accumulo.image.tag=${GAFFER_VERSION} \
  --set api.image.tag=${GAFFER_VERSION}

helm test gaffer
```
