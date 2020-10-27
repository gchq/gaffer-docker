How to deploy a simple graph
==================================
This guide will describe how to deploy a simple empty graph with the minimum configuration.

You will need:
1. Helm
2. Kubectl
3. A Kubernetes cluster (local or remote)

### Add the Gaffer Docker repo
To start with, you should add the Gaffer Docker repo to your helm repos. This will save the need for
cloning this Git repository. If you've already done this, you can skip this step.
```bash
helm repo add gaffer-docker https://gchq.github.io/gaffer-docker
```

### Set the Accumulo passwords
By default, we don't set the Accumulo passwords for you. To set these create a file called `password-values.yaml` and add the following:

```yaml
accumulo:
  config:
    accumuloSite:
      instance.secret: "DEFAULT"
    userManagement:
      rootPassword: "root"
      users:
        gaffer:
          password: "gaffer"
        tracer:
          password: "tracer"
```
Replace the default values with your own. Once this is deployed you cannot change it.

### Deploy the default Gaffer Graph
You can now deploy the default Gaffer Graph with a default schema. The first time you deploy
Gaffer it can take around 5 minutes for everything to start so it may be worth adding `--timeout 10m0s` to this command.
```bash
helm install my-graph gaffer-docker/gaffer -f password-values.yaml
```
Feel free to change "my-graph" to something more interesting.

### What next?
See our [guides](./guides.md) for other things you can do with Gaffer on Kubernetes.