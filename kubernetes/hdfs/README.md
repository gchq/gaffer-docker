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
kubectl port-forward svc/hdfs-namenodes 8080:9870
```

Access the HDFS web UI at: http://localhost:8080

### Known Issues

Data nodes may fail to register with the name node. Logs for data node pods contain:
```
WARN datanode.DataNode: Problem connecting to server: hdfs-namenode-0.hdfs-namenodes:8021
```
This is because data nodes lookup the IP address for the name node when they first start up, and cache the response. If they perform the lookup before the name node service is registered in DNS then they will cache the null response and will fail to connect to the name node indefinitely.

Workaround: Restart the data node pods after the name server is up so that they can resolve the IP.

Fix: Build the [HDFS container](../../docker/hdfs/) image with a Hadoop distribution that has [HADOOP-15129](https://jira.apache.org/jira/browse/HADOOP-15129) applied to it.
