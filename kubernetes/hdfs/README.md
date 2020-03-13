### Deploying using [kind](https://kind.sigs.k8s.io/)

Pre-reqs:
* Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* Install [Helm](https://github.com/helm/helm/releases)
* Install [kind](https://kind.sigs.k8s.io/docs/user/quick-start/)
* Ensure you have built the HDFS container image [here](../../docker/hdfs/) e.g. `docker-compose build`

```
kind create cluster
kind load docker-image gchq/hdfs:3.2.1
helm install hdfs .
helm test hdfs
kubectl port-forward svc/hdfs-namenodes 8080:80
```

Access the HDFS web UI at: http://localhost:8080
