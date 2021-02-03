Changing the Graph Id and Description
=======================================
By default, the default Gaffer deployment ships with the Graph name "simpleGraph" and description "A  graph for demo purposes" These are just placeholders and can be overwritten. This guide will show you how.

The first thing you'll need to do is [deploy an empty graph](./deploy-empty-graph.md).

### Changing the description
Create a file called `graph-meta.yaml`. We will use this file to add our description and graph Id.
Changing the description is as easy as changing the `graph.config.description` value.
```yaml
graph:
  config:
    description: "My graph description"
```
Feel free to be a bit more imaginative.

### Deploy the new description
Upgrade your deployment using helm:

```bash
helm upgrade my-graph gaffer-docker/gaffer -f graph-metadata.yaml --reuse-values
```

The `--reuse-values` argument means we don't override any passwords that we set in the initial construction.

You can see your new description if you go to the Swagger UI and call the /graph/config/description endpoint.

### Updating the Graph Id

This may be simple or complicated depending on your store type. If your're using the Map or Federated store, you can just set the
`graph.config.graphId` value in the same way. Though if you're using a MapStore, the graph will be emptied as a result.

However if you're using the Accumulo store, updating the graph Id is a little more complicated since the Graph Id corresponds to an Accumulo table. We have to change the gaffer user's permissions to read and write to that table. To do that update the `graph-meta.yaml` file with the following contents:
```yaml
graph:
  config:
    graphId: "MyGraph"
    description: "My Graph description"

accumulo:
  config:
    userManagement:
      users:
        gaffer:
          permissions:
            table:
              MyGraph:
              - READ
              - WRITE
              - BULK_IMPORT
              - ALTER_TABLE
```

### Deploy your changes
Upgrade your deployment using Helm.
```bash
helm upgrade my-graph gaffer-docker/gaffer -f graph-metadata.yaml --reuse-values
```

If you take a look at the Accumulo monitor, you will see your new Accumulo table

### What next?
See our [guides](./guides.md) for other things you can do with Gaffer on Kubernetes.
