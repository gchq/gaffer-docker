# Gaffer REST Federated Example

This is an example deployment of Gaffer's federation feature. This uses a
REST API deployment of Gaffer to which two in memory sub graphs are added
which can be queried across.

The example uses a split version of the
[Tinkerpop Modern Graph](https://tinkerpop.apache.org/docs/current/tutorials/the-gremlin-console/#toy-graphs)
where all the `knows` edges are in one graph with ID: `knowsGraph` and all
the `created` and `software` vertexes are in another with graph ID: `createdGraph`.
This leaves the `people` vertexes common across both graphs so that when
federated it will appear as the original Modern graph data.

## Running the Example

To run the example please use the provided start script with an environment file
to specify the image versions e.g. `accumulo2.env`:

```bash
./create-deployment.sh ../../accumulo2.env
```

With the demo deployment a standard Gaffer REST API will be started (available
on port 8080 by default). The deployment uses map stores to store two sub graphs
that can be federated across. Basic configuration for federation has been added
(under the `config` directory) but can be modified to test out different
scenarios, please see the [documentation](https://gchq.github.io/gaffer-doc/latest/administration-guide/gaffer-stores/federated-store.html)
for more information.
