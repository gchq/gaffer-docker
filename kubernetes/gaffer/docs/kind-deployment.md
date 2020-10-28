# Deploying Gaffer using kind
All the scripts found here are designed to be run from the kubernetes/gaffer folder.

First follow the [instructions here](../../docs/kind-deployment.md) to provision and configure a local Kubernetes cluster, using [kind](https://kind.sigs.k8s.io/) (Kubernetes IN Docker), that the Gaffer Helm Chart can be deployed on.

Then update the Accumulo users' passwords in the values.yaml file. These are found under `accumulo.config.userManagement`.

Gaffer is then ready be deployed:

```bash
export HADOOP_VERSION=${HADOOP_VERSION:-3.2.1}
export GAFFER_VERSION=${GAFFER_VERSION:-1.13.4}

helm dependency update

helm install gaffer . \
  --set hdfs.namenode.tag=${HADOOP_VERSION} \
  --set hdfs.datanode.tag=${HADOOP_VERSION} \
  --set hdfs.shell.tag=${HADOOP_VERSION} \
  --set accumulo.image.tag=${GAFFER_VERSION} \
  --set api.image.tag=${GAFFER_VERSION}

helm test gaffer
```


## Accessing Web UIs (via `kubectl port-forward`)

| Component   | Command                                                    | URL                         |
| ----------- | ---------------------------------------------------------- | --------------------------- |
| HDFS        | `kubectl port-forward svc/gaffer-hdfs-namenodes 9870:9870` | http://localhost:9870/      |
| Accumulo    | `kubectl port-forward svc/gaffer-monitor 9995:80`          | http://localhost:9995/      |
| Gaffer Web  | `kubectl port-forward svc/gaffer-api 8080:80`              | http://localhost:8080/ui/   |
| Gaffer REST | `kubectl port-forward svc/gaffer-api 8080:80`              | http://localhost:8080/rest/ |


## Accessing Web UIs (via [Nginx Ingress Controller](https://github.com/kubernetes/ingress-nginx))

Register the FQDNs for each component in DNS e.g.
```
echo "127.0.0.1 gaffer.k8s.local accumulo.k8s.local hdfs.k8s.local" | sudo tee -a /etc/hosts
```

Update the Gaffer deployment to route ingress based on FQDNs:
```
helm upgrade gaffer . -f ./values-host-based-ingress.yaml --reuse-values
```

Set up port forwarding to the nginx ingress controller:
```
sudo KUBECONFIG=$HOME/.kube/config kubectl port-forward -n ingress-nginx svc/ingress-nginx 80:80
```

Access the web UIs using the following URLs:
| Component   | URL                           |
| ----------- | ----------------------------- |
| HDFS        | http://hdfs.k8s.local/        |
| Accumulo    | http://accumulo.k8s.local/    |
| Gaffer Web  | http://gaffer.k8s.local/ui/   |
| Gaffer REST | http://gaffer.k8s.local/rest/ |
