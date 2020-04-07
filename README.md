This repo contains Dockerfiles for building container images for:
* [HDFS](docker/hdfs/)
* [Accumulo](docker/accumulo/)
* [Gaffer](docker/gaffer/)
* Gaffer's [REST API and Web UI](docker/gaffer-wildfly/)
* Gaffer's [Road Traffic Data Loader](docker/gaffer-road-traffic-loader/)

It also contains Helm Charts so that the following applications can be deployed onto Kubernetes clusters:
* [HDFS](kubernetes/hdfs/)
* [Gaffer](kubernetes/gaffer/)
* [Example Gaffer Graph containing Road Traffic Dataset](kubernetes/gaffer-road-traffic/)

There are guides on how to deploy the charts on:
* a local Kubernetes cluster, [using kind (Kubernetes IN Docker)](kubernetes/kind-deployment.md)
* an [AWS EKS cluster](kubernetes/aws-eks-deployment.md)
