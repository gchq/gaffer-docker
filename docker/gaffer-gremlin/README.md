# gaffer-gremlin

## Build

Run the supplied `build.sh` script with the required environment vars to pull
all dependencies and build the container.

_Note requires Maven and Docker_

Optionally run each command separately to configure the containers tags etc.

## Configure

The container will use the Gaffer Proxy store to connect to an existing graph
and provide a Gremlin endpoint to connect to (see the [Tinkerpop docs](https://tinkerpop.apache.org/docs/current/reference/#connecting-gremlin-server)).

The Gaffer graph the container will connect to can be configured as usual by
editing the `store.properties` file, which you can also bind mount over on an
existing image.

The configuration for the Gremlin server is provided by the `gaffer-gremlin-server.yaml`
this again can be modified as needed or bind mounted over. Please see the
[official Gaffer docs](https://gchq.github.io/gaffer-doc/latest/administration-guide/gaffer-deployment/gremlin/)
for more information on configuring this image.

## Run

Simply run the container to publish the Gremlin server this can then be
connected to via the address specified in the server's yaml config to use
Gremlin traversal. The server can then be connected via the Gremlin
console e.g. if using python

```python
from gremlin_python.process.anonymous_traversal_source import traversal

g = traversal().withRemote(
    DriverRemoteConnection('ws://localhost:8182/gremlin'))
```
