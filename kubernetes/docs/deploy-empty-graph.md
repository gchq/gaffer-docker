How to deploy a simple graph
==================================
This guide will describe how to deploy a simple empty graph with the minimum configuration.

You will need:
1. Helm
2. Kubectl
3. A Kubernetes cluster (local or remote)
4. An ingress controller running (for accessing UI's)

### Add the Gaffer Docker repo
To start with, you should add the Gaffer Docker repo to your helm repos. This will save the need for
cloning this Git repository. If you've already done this, you can skip this step.
```bash
helm repo add gaffer-docker https://gchq.github.io/gaffer-docker
```
### Choose the store

Gaffer can be backed with a number of different technologies to back it's store. Which one you want depends on the use case but as a rule of thumb:
If you just want something to spin up quickly at small scale and arn't worried about persistance: use the [Map Store](#deploy-the-map-store).

If you want to back it with a key value datastore, you can deploy the [Accumulo Store](#deploy-the-accumulo-store)

If you want to join two or more graphs together to query them as one, you'll want to use the [Federated Store](#deploy-the-federated-store)

Other stores such as parquet or hbase could be supported by this helm chart if you wanted, but support for it isn't there just yet. You can request it by [raising an issue](https://github.com/gchq/gaffer-docker/issues/new)


#### Deploy the Map Store

The Map store is just an in memory store that can be used for demos or if you need something small scale short term. It is our default store so there's no need for any extra configuration.

You can install a Map Store by just running:
```bash
helm install my-graph gaffer-docker/gaffer
```

#### Deploy the Accumulo Store

If you want to deploy Accumulo with your graph, that's relatively easy to do. We are going to need some extra configuration though. Create a file called `accumulo.yaml` and add the following.

```yaml
accumulo:
  enabled: true
```

By default, the gaffer user is created with a password of "gaffer" the `CREATE_TABLE` system permission with full access to 
the `simpleGraph` table which is coupled to the graphId. All the default accumulo passwords are in place so if you were to
deploy this in production, you should consider [changing the default accumulo passwords](./change-accumulo-passwords.md).

You can stand up the accumulo store by running:
```bash
helm install my-graph gaffer-docker/gaffer -f accumulo.yaml
```

#### Deploy the Federated Store

If you want to deploy the Federated Store, all that you really need to do is set the store.properties and set the ui config. Add this to a `federated.yaml` file:

```yaml
graph:
  storeProperties:
    gaffer.store.class: uk.gov.gchq.gaffer.federatedstore.FederatedStore
    gaffer.store.properties.class: uk.gov.gchq.gaffer.federatedstore.FederatedStoreProperties
    gaffer.serialiser.json.modules: uk.gov.gchq.gaffer.sketches.serialisation.json.SketchesJsonModules
```

The addition of the SketchesJsonModules is just to ensure that if the FederatedStore was connecting to a store which used sketches, they could be rendered nicely in json.

Now to set the config.json, it's probably easier to use a seperate `ui-config.json` file with the following contents:
```json
{
  "gafferEndpoint": {
    "path": "/rest"
  },
  "operationOptions": {
    "visible": [
      {
        "key": "gaffer.federatedstore.operation.graphIds",
        "label": "Graph Ids",
        "multiple": true,
        "autocomplete": {
          "asyncOptions": {
            "class": "GetAllGraphIds"
          }
        }
      },
      {
        "key": "gaffer.federatedstore.operation.skipFailedFederatedStoreExecute",
        "label": "Skip Failed Graphs",
        "value": "false",
        "autocomplete": {
          "options": [ "true", "false" ]
        }
      }
    ]
  }
}
```

Now that you've got the ability to set graph Ids from the UI, we can create the graph:

```
helm install federated gaffer-docker/gaffer -f federated.yaml --set-file ui.config=./ui-config.json
```


### What next?
See our [guides](./guides.md) for other things you can do with Gaffer on Kubernetes.
