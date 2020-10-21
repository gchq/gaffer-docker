How to Deploy your own Schema
==============================
Gaffer uses schema files to describe the data contained in a Graph. This guide will tell you how
to deploy your own schemas with a Gaffer Graph.

The first thing you'll need to do is deploy a simple graph. We have a guide for how to do that [here](./deploy-empty-graph.md).

Once you have that deployed, we can change the schema.

### Edit the schema
If you run a GetSchema operation against the graph, you'll notice that the count property is of
type `java.lang.Integer`. Let's change that property to be of type `java.lang.Long`.

Create a new file called `schema-values.yaml`. we can change the schema by changing the `graph.schema` value. This value is a map from filename to file contents. It will be added to the REST service and Accumulo iterators.

schema-values.yaml
```yaml
graph:
  schema:
    schema.jaon: -|
      {
        "edges": {
          "BasicEdge": {
            "source": "vertex",
            "destination": "vertex",
            "directed": "true",
            "properties": {
                "count": "count"
            }
          }
        },
        "entities": {
          "BasicEntity": {
            "vertex": "vertex",
            "properties": {
                "count": "count"
            }
          }
        },
        "types": {
          "vertex": {
            "class": "java.lang.String"
          },
          "count": {
            "class": "java.lang.Long",
            "aggregateFunction": {
                "class": "uk.gov.gchq.koryphe.impl.binaryoperator.Sum"
            }
          },
          "true": {
            "description": "A simple boolean that must always be true.",
            "class": "java.lang.Boolean",
            "validateFunctions": [
                { "class": "uk.gov.gchq.koryphe.impl.predicate.IsTrue" }
            ]
          }
        }
      }
```

### Update deployment with the new schema
For our deployment to pick up the changes, we need to run a helm upgrade:
```bash
helm upgrade my-graph gaffer-docker/gaffer -f schema-values.yaml --reuse-values
```
The `--reuse-values` argument tells helm to re-use the passwords that we defined earlier.

Now if we inspect the schema, you'll see that the `count` property has changed to a Long.


### What next?
See our [guides](./guides.md) for other things you can do with Gaffer on Kubernetes.
