# Gaffer Modern Example

This is an example deployment of Gaffer on Accumulo. This uses a REST API
deployment of Gaffer with full Accumulo and Hadoop storage backing.

The example uses the
[Tinkerpop Modern Graph](https://tinkerpop.apache.org/docs/current/tutorials/the-gremlin-console/#toy-graphs)
as its data set to demonstrate basic querying of data. The data can be queried
via the REST API using standard Gaffer operations or by using the Gremlin
websocket (see [the docs](https://gchq.github.io/gaffer-doc/latest/user-guide/query/gremlin/gremlin.html)
for more info).

## Running the Example

To run the example please use the provided start script with an environment file
to specify the image versions e.g. `accumulo2.env`:

```bash
./create-deployment.sh ../../accumulo2.env
```

With the demo deployment a standard Gaffer REST API will be started (available
on port 8080 by default). Basic configuration for Accumulo and Hadoop have been
added but can be modified to test out different
scenarios, please see the [documentation](https://gchq.github.io/gaffer-doc/latest/administration-guide/gaffer-stores/accumulo-store.html)
for more information.
