# Deploying JupyterHub for Gaffer using kind

All scripts listed here are intended to be run from the `kubernetes/gaffer-jhub` folder.

First, follow the [instructions here](../../gaffer-road-traffic/docs/kind-deployment.md) to provision and configure a local Kubernetes cluster, using [kind](https://kind.sigs.k8s.io/) (Kubernetes IN Docker), that has an instance of the Gaffer Road Traffic example graph deployed into it.

Once that's done, use the following commands to deploy a JupyterHub instance with Gaffer extensions:
```bash
helm dependency update
helm install jhub . -f ./values-insecure.yaml

helm test jhub
```

## Accessing JupyterHub Web UIs (via `kubectl port-forward`)

Run the following on the command line:
```bash
kubectl port-forward svc/proxy-public 8080:80
```

Access the following URL in your browser: 
http://localhost:8080

By default, JupyterHub's Dummy Authenticator is used so you can login using any username and password.

