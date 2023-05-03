Deploying Accumulo using kind
=================================

All the scripts found here are designed to be run from the kubernetes/accumulo folder.

First follow the [instructions here](../../docs/kind-deployment.md) to provision and configure a local Kubernetes cluster, using [kind](https://kind.sigs.k8s.io/) (Kubernetes IN Docker), that the Accumulo Helm Chart can be deployed on.

```bash
export HADOOP_VERSION=${HADOOP_VERSION:-3.3.3}
export GAFFER_VERSION=${GAFFER_VERSION:-2.0.0-alpha-0.5}

helm dependency update

helm install accumulo . \
  --set hdfs.namenode.tag=${HADOOP_VERSION} \
  --set hdfs.datanode.tag=${HADOOP_VERSION} \
  --set hdfs.shell.tag=${HADOOP_VERSION} \
  --set accumulo.image.tag=${GAFFER_VERSION}

helm test accumulo
```

# Accessing Web UIs (via `kubectl port-forward`)
| Component   | Command                                                          | URL                         |
| ----------- | ---------------------------------------------------------------- | --------------------------- |
| Accumulo    | `kubectl port-forward svc/road-traffic-gaffer-monitor 9995:80`   | http://localhost:9995/      |


# Accessing Web UIs (via [Nginx Ingress Controller](https://github.com/kubernetes/ingress-nginx))
Register the FQDNs for each component in DNS e.g.
```
echo "127.0.0.1 gaffer.k8s.local accumulo.k8s.local hdfs.k8s.local" | sudo tee -a /etc/hosts
```

Update the Gaffer deployment to route ingress based on FQDNs:
```
helm upgrade accumulo . -f ./values-host-based-ingress.yaml --reuse-values
```

Set up port forwarding to the nginx ingress controller:
```
sudo KUBECONFIG=$HOME/.kube/config kubectl port-forward -n ingress-nginx svc/ingress-nginx 80:80
```

Access the web UIs using the following URLs:
| Component   | URL                           |
| ----------- | ----------------------------- |
| Accumulo    | http://accumulo.k8s.local/    |