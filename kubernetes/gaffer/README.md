### Deploying using [kind](https://kind.sigs.k8s.io/)

Pre-reqs:
* Install [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* Install [Helm](https://github.com/helm/helm/releases)
* Install [kind](https://kind.sigs.k8s.io/docs/user/quick-start/)
* Ensure you have built the [HDFS](../../docker/hdfs/), [Accumulo](../../docker/accumulo/), [Gaffer](../../docker/gaffer/) and [gaffer-wildfly](../../docker/gaffer-wildfly/) container images e.g.
  ```
  docker-compose --project-directory ../../docker/accumulo/ -f ../../docker/accumulo/docker-compose.yaml build
  docker-compose --project-directory ../../docker/gaffer/ -f ../../docker/gaffer/docker-compose.yaml build
  ```

Deployment:
```
kind create cluster
kind load docker-image gchq/hdfs:3.2.1
kind load docker-image gchq/gaffer:1.11.0
kind load docker-image gchq/gaffer-wildfly:1.11.0
helm dependency update
helm install gaffer .
helm test gaffer
```

### Accessing Web UIs (via `kubectl port-forward`)

| Component   | Command                                                    | URL                    |
| ----------- | ---------------------------------------------------------- | ---------------------- |
| HDFS        | `kubectl port-forward svc/gaffer-hdfs-namenodes 9870:9870` | http://localhost:9870/ |
| Accumulo    | `kubectl port-forward svc/gaffer-monitor 9995:80`          | http://localhost:9995/ |
| Gaffer Web  | `kubectl port-forward svc/gaffer-api 8080:80`              | http://localhost:8080/ |
| Gaffer REST | `kubectl port-forward svc/gaffer-api 8080:80`              | http://localhost:8080/ |
