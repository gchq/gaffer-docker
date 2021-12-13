# Deploying Road Traffic Gaffer Graph using kind
All scripts listed here are intended to be run from the kubernetes/gaffer-road-traffic folder

First follow the [instructions here](../../docs/kind-deployment.md) to provision and configure a local Kubernetes cluster, using [kind](https://kind.sigs.k8s.io/) (Kubernetes IN Docker), that the Gaffer Road Traffic Helm Chart can be deployed on.

After the cluster is provisioned, update the values.yaml with the passwords for the various accumulo users. These are found under `accumulo.config.userManagement`.

Once that's done, run this to deploy and test the Road Traffic Graph. 
```bash
export HADOOP_VERSION=${HADOOP_VERSION:-3.2.1}
export GAFFER_VERSION=${GAFFER_VERSION:-1.21.1}

helm dependency update ../accumulo/
helm dependency update ../gaffer/
helm dependency update

helm install road-traffic . \
  --set gaffer.hdfs.namenode.tag=${HADOOP_VERSION} \
  --set gaffer.hdfs.datanode.tag=${HADOOP_VERSION} \
  --set gaffer.hdfs.shell.tag=${HADOOP_VERSION} \
  --set gaffer.accumulo.image.tag=${GAFFER_VERSION} \
  --set gaffer.api.image.tag=${GAFFER_VERSION} \
  --set loader.image.tag=${GAFFER_VERSION}

helm test road-traffic
```


## Accessing Web UIs (via `kubectl port-forward`)

| Component   | Command                                                          | URL                         |
| ----------- | ---------------------------------------------------------------- | --------------------------- |
| HDFS        | `kubectl port-forward svc/road-traffic-hdfs-namenodes 9870:9870` | http://localhost:9870/      |
| Accumulo    | `kubectl port-forward svc/road-traffic-gaffer-monitor 9995:80`   | http://localhost:9995/      |
| Gaffer Web  | `kubectl port-forward svc/road-traffic-gaffer-api 8080:80`       | http://localhost:8080/ui/   |
| Gaffer REST | `kubectl port-forward svc/road-traffic-gaffer-api 8080:80`       | http://localhost:8080/rest/ |


## Accessing Web UIs (via [Nginx Ingress Controller](https://github.com/kubernetes/ingress-nginx))

Register the FQDNs for each component in DNS e.g.
```
echo "127.0.0.1 gaffer.k8s.local accumulo.k8s.local hdfs.k8s.local" | sudo tee -a /etc/hosts
```

Update the Gaffer deployment to route ingress based on FQDNs:
```
helm upgrade road-traffic . -f ./values-host-based-ingress.yaml --reuse-values
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
