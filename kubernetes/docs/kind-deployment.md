# Deploying using kind

The following instructions will guide you through provisioning and configuring a local Kubernetes cluster, using [kind](https://kind.sigs.k8s.io/) (Kubernetes IN Docker), that our Helm Charts can be deployed on.


## Install CLI Tools

* [docker-compose](https://github.com/docker/compose/releases/latest)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [helm](https://github.com/helm/helm/releases)
* [kind](https://kind.sigs.k8s.io/docs/user/quick-start/)


## Kubernetes Cluster

Simply run the following command to spin up a local Kubernetes cluster, running inside a Docker container:
```
kind create cluster
```


## Container Images

If the versions of the container images you would like to deploy are not available in [Docker Hub](https://hub.docker.com/u/gchq) then you will need to build them yourself and import them into your kind cluster. 

To import the images, run this from the kubernetes directory:

```bash
export HADOOP_VERSION=${HADOOP_VERSION:-3.2.1}
export GAFFER_VERSION=${GAFFER_VERSION:-1.21.1}
export GAFFER_TOOLS_VERSION=${GAFFER_TOOLS_VERSION:-1.21.1}

docker-compose --project-directory ../docker/accumulo/ -f ../docker/accumulo/docker-compose.yaml build
docker-compose --project-directory ../docker/gaffer-ui -f ../docker/gaffer-ui/docker-compose.yaml build
docker-compose --project-directory ../docker/gaffer-operation-runner/ -f ../docker/gaffer-operation-runner/docker-compose.yaml build

kind load docker-image gchq/hdfs:${HADOOP_VERSION}
kind load docker-image gchq/gaffer:${GAFFER_VERSION}
kind load docker-image gchq/gaffer-rest:${GAFFER_VERSION}
kind load docker-image gchq/gaffer-ui:${GAFFER_TOOLS_VERSION}
kind load docker-image gchq/gaffer-road-traffic-loader:${GAFFER_VERSION}
kind load docker-image gchq/gaffer-operation-runner:${GAFFER_VERSION}
```

## Ingress

Deploy the Nginx Ingress Controller:
```
INGRESS_NGINX_VERSION="nginx-0.30.0"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/${INGRESS_NGINX_VERSION}/deploy/static/mandatory.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/${INGRESS_NGINX_VERSION}/deploy/static/provider/baremetal/service-nodeport.yaml
```

## Deploy Helm Charts

* [HDFS](../hdfs/docs/kind-deployment.md)
* [Gaffer](../gaffer/docs/kind-deployment.md)
* [Example Gaffer Graph containing Road Traffic Dataset](../gaffer-road-traffic/docs/kind-deployment.md)


## Uninstall

```
kind delete cluster
```
