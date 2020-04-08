# Deploying using kind

The following instructions will guide you through provisioning and configuring a local Kubernetes cluster, using [kind](https://kind.sigs.k8s.io/) (Kubernetes IN Docker), that our Helm Charts can be deployed on.


## Install CLI Tools

* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [helm](https://github.com/helm/helm/releases)
* [kind](https://kind.sigs.k8s.io/docs/user/quick-start/)


## Kubernetes Cluster

Simply run the following command to spin up a local Kubernetes cluster, running inside a Docker container:
```
kind create cluster
```


## Container Images

If the versions of the container images you would like to deploy are not available in [Docker Hub](https://hub.docker.com/u/gchq) then you will need to build them yourself and import them into your kind cluster:
```
export HADOOP_VERSION=${HADOOP_VERSION:-3.2.1}
export GAFFER_VERSION=${GAFFER_VERSION:-1.11.0}
export GAFFER_TOOLS_VERSION=${GAFFER_TOOLS_VERSION:-$GAFFER_VERSION}

docker-compose --project-directory ../docker/accumulo/ -f ../docker/accumulo/docker-compose.yaml build
docker-compose --project-directory ../docker/gaffer-road-traffic-loader/ -f ../docker/gaffer-road-traffic-loader/docker-compose.yaml build

kind load docker-image gchq/hdfs:${HADOOP_VERSION}
kind load docker-image gchq/gaffer:${GAFFER_VERSION}
kind load docker-image gchq/gaffer-rest:${GAFFER_VERSION}
kind load docker-image gchq/gaffer-road-traffic-loader:${GAFFER_VERSION}
```


## Deploy Helm Charts

* [HDFS](hdfs/docs/kind-deployment.md)
* [Gaffer](gaffer/docs/kind-deployment.md)
* [Example Gaffer Graph containing Road Traffic Dataset](gaffer-road-traffic/docs/kind-deployment.md)


## Accessing Web UIs (via `kubectl port-forward`)

| Component   | Command                                                    | URL                    |
| ----------- | ---------------------------------------------------------- | ---------------------- |
| HDFS        | `kubectl port-forward svc/gaffer-hdfs-namenodes 9870:9870` | http://localhost:9870/ |
| Accumulo    | `kubectl port-forward svc/gaffer-monitor 9995:80`          | http://localhost:9995/ |
| Gaffer Web  | `kubectl port-forward svc/gaffer-api 8080:80`              | http://localhost:8080/ |
| Gaffer REST | `kubectl port-forward svc/gaffer-api 8080:80`              | http://localhost:8080/ |

## Accessing Web UIs (via [Nginx Ingress Controller](https://github.com/kubernetes/ingress-nginx))

Register the FQDNs for each component in DNS e.g.
```
echo "127.0.0.1 gaffer.k8s.local accumulo.k8s.local hdfs.k8s.local" | sudo tee -a /etc/hosts
```

Update the Gaffer deployment to route ingress based on FQDNs:
```
helm upgrade gaffer . -f ./values-host-based-ingress.yaml
```

Deploy the Nginx Ingress Controller:
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/service-nodeport.yaml
sudo KUBECONFIG=$HOME/.kube/config kubectl port-forward -n ingress-nginx svc/ingress-nginx 80:80
```

Access the web UIs using the following URLs:
| Component   | URL                           |
| ----------- | ----------------------------- |
| HDFS        | http://hdfs.k8s.local/        |
| Accumulo    | http://accumulo.k8s.local/    |
| Gaffer Web  | http://gaffer.k8s.local/ui/   |
| Gaffer REST | http://gaffer.k8s.local/rest/ |


## Uninstall

```
kind delete cluster
```
