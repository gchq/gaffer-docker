Deploying JupyterHub for Gaffer using kind
==========================================

All scripts listed here are intended to be run from the `kubernetes/gaffer-jhub` folder.

First, follow the [instructions here](../../gaffer-road-traffic/docs/kind-deployment.md) to provision and configure a local Kubernetes cluster, using [kind](https://kind.sigs.k8s.io/) (Kubernetes IN Docker), that has an instance of the Gaffer Road Traffic example graph deployed into it.


# Container Images

Use the following commands to build and deploy the extra containers used by JupyterHub:
```bash
source ../../docker/gaffer-pyspark-notebook/.env
source ../../docker/gaffer-jhub-options-server/get-version.sh

# Build Container Images
docker-compose --project-directory ../../docker/gaffer-pyspark-notebook/ -f ../../docker/gaffer-pyspark-notebook/docker-compose.yaml build notebook
docker-compose --project-directory ../../docker/spark-py/ -f ../../docker/spark-py/docker-compose.yaml build
docker-compose --project-directory ../../docker/gaffer-jhub-options-server/ -f ../../docker/gaffer-jhub-options-server/docker-compose.yaml build

# Deploy Images to Kind
kind load docker-image gchq/gaffer-pyspark-notebook:${GAFFER_VERSION}
kind load docker-image gchq/spark-py:${SPARK_VERSION}
kind load docker-image gchq/gaffer-jhub-options-server:${JHUB_OPTIONS_SERVER_VERSION}
```

# Deploy Helm Chart

Once that's done, use the following commands to deploy a JupyterHub instance with Gaffer extensions:
```bash
helm dependency update
helm install jhub . -f ./values-insecure.yaml

helm test jhub
```

# Accessing JupyterHub Web UIs (via `kubectl port-forward`)

Run the following on the command line:
```bash
kubectl port-forward svc/proxy-public 8080:80
```

Access the following URL in your browser: 
http://localhost:8080

By default, JupyterHub's Dummy Authenticator is used so you can login using any username and password.


# Accessing example notebooks

There are some example notebooks that demonstrate how to interact with HDFS, Gaffer and Spark. Copy them into your working directory, to make them easier to view and execute, by starting a Terminal tab and submitting the following command:
```bash
$ cp -r /examples .
```

