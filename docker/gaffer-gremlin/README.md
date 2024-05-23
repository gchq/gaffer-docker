# gaffer-gremlin

## Build

Run the supplied `build.sh` script with the required environment vars (can
source `accumolo2.env` file) to pull all dependencies and build the container.

_Note requires Maven and Docker_

Optionally run each command separately to configure the containers tags etc.

## Configure

The container will use the Gaffer Proxy store by default to connect to an
existing graph and provide a Gremlin endpoint to connect to (see the [Tinkerpop docs](https://tinkerpop.apache.org/docs/current/reference/#connecting-gremlin-server)).

The Gaffer graph the container will connect to can be configured as usual by
editing the `store.properties` file, which you can also bind mount over on an
existing image. The config file locations are under the predefined workdir
set by the parent gremlin server image the key locations in the image are:

- `/opt/gremlin-server/conf/gaffer/store.properties` - Override for custom store properties.
- `/opt/gremlin-server/conf/gafferpop/gafferpop.properties` - Override to configure the graph.

The configuration for the Gremlin server is provided by the `gaffer-gremlin-server.yaml`
this again can be modified as needed or bind mounted over. Please see the
[official Gaffer docs](https://gchq.github.io/gaffer-doc/latest/administration-guide/gaffer-deployment/gremlin/)
for more information on configuring this image.

## Run

Simply run the container to publish the Gremlin server making sure to make the
configured port available (port 8182 by default) this can then be connected to
via the address specified in the server's yaml config to use Gremlin traversal.
The server can then be connected via the Gremlin console e.g. if using
`gremlinpython`:

```python
from gremlin_python.process.anonymous_traversal_source import traversal

g = traversal().withRemote(
    DriverRemoteConnection('ws://localhost:8182/gremlin', 'g'))
```

### Demo Deployment

A demo/example using the tinkerpop 'modern' dataset and accumulo backed Gaffer
is available under the `example` directory. This can be ran using docker compose
to deploy the containers. The provided jupyter notebooks demonstrate how to
connect to your graph and some basic Gremlin queries on the data using `gremlinpython` or via
`graph-notebook` (note this requires the [graph-notebook extension](https://github.com/aws/graph-notebook)).

To run the example please use the provided start script with an environment file
to specify the image versions e.g. `accumulo2.env`:

```bash
./example/create-deployment.sh ../accumulo2.env
```

With the demo deployment both a standard Gaffer REST API and Gaffer Gremlin
server will be started (available on port 8080 and 8182 respectively). The
deployment uses a small scale Accumulo instance as the Gaffer store backing,
see [the docs](https://gchq.github.io/gaffer-doc/latest/administration-guide/gaffer-stores/accumulo-store/)
for more configuration options.
