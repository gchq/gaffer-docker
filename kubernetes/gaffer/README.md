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
kubectl wait po -l app.kubernetes.io/instance=gaffer,app.kubernetes.io/name=gaffer --for=condition=Ready --timeout=10m
helm test gaffer
```

### Accessing Web UIs (via `kubectl port-forward`)

| Component   | Command                                                    | URL                    |
| ----------- | ---------------------------------------------------------- | ---------------------- |
| HDFS        | `kubectl port-forward svc/gaffer-hdfs-namenodes 9870:9870` | http://localhost:9870/ |
| Accumulo    | `kubectl port-forward svc/gaffer-monitor 9995:80`          | http://localhost:9995/ |
| Gaffer Web  | `kubectl port-forward svc/gaffer-api 8080:80`              | http://localhost:8080/ |
| Gaffer REST | `kubectl port-forward svc/gaffer-api 8080:80`              | http://localhost:8080/ |

### Accessing Web UIs (via [Nginx Ingress Controller](https://github.com/kubernetes/ingress-nginx))

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

