How to deploy a simple graph
=============================
This guide will describe how to deploy a simple empty graph with the minimum configuration.

You will need:
1. Helm
2. Kubectl
3. A Kubernetes cluster (local or remote)
4. An ingress controller running (for accessing UIs)

# Add the Gaffer Docker repo
To start with, you should add the Gaffer Docker repo to your helm repos. This will save the need for cloning this Git repository. If you have already done this, you can skip this step.
```bash
helm repo add gaffer-docker https://gchq.github.io/gaffer-docker
```

# Choose the store
Gaffer can be backed with a number of different technologies to back its store. Which one you want depends on the use case but as a rule of thumb:
* If you just want something to spin up quickly at small scale and are not worried about persistance: use the [Map Store](#deploy-the-map-store).
* If you want to back it with a key value datastore, you can deploy the [Accumulo Store](#deploy-the-accumulo-store)
* If you want to join two or more graphs together to query them as one, you will want to use the [Federated Store](#deploy-the-federated-store)

Other stores such as parquet or hbase could be supported by this helm chart if you wanted, but support for it is not available yet.

## Deploy the Map Store
The Map store is just an in memory store that can be used for demos or if you need something small scale short term. It is our default store so there is no need for any extra configuration.

You can install a Map Store by just running:
```bash
helm install my-graph gaffer-docker/gaffer
```

## Deploy the Accumulo Store
If you want to deploy Accumulo with your graph, it is relatively easy to do so with some small additional configuration. 
Create a file called `accumulo.yaml` and add the following:
```yaml
accumulo:
  enabled: true
```

By default, the Gaffer user is created with a password of "gaffer" the `CREATE_TABLE` system permission with full access to the `simpleGraph` table which is coupled to the graphId. All the default Accumulo passwords are in place so if you were to deploy this in production, you should consider [changing the default accumulo passwords](./change-accumulo-passwords.md).

You can stand up the accumulo store by running:
```bash
helm install my-graph gaffer-docker/gaffer -f accumulo.yaml
```

## Deploy the Federated Store
If you want to deploy the Federated Store, all that you really need to do is set the store.properties. 
To do this add the following to a `federated.yaml` file:

```yaml
graph:
  storeProperties:
    gaffer.store.class: uk.gov.gchq.gaffer.federatedstore.FederatedStore
    gaffer.store.properties.class: uk.gov.gchq.gaffer.federatedstore.FederatedStoreProperties
    gaffer.serialiser.json.modules: uk.gov.gchq.gaffer.sketches.serialisation.json.SketchesJsonModules
```

The addition of the SketchesJsonModules is just to ensure that if the FederatedStore was connecting to a store which used sketches, they could be rendered nicely in json.

We can create the graph with:

```
helm install federated gaffer-docker/gaffer -f federated.yaml
```

# What next?
See our [guides](./guides.md) for other things you can do with Gaffer on Kubernetes.
