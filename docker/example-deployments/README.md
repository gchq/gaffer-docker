# Example Gaffer Deployments

These directories have basic examples of deploying containerised Gaffer with
different store backings. Some example notebooks are also available which
primarily feature the use of the Gremlin interface for interacting with the
Graph.

All examples will provide a Gaffer REST API to start interacting with the
deployed graph.

## Modern Example (Accumulo)

The modern example, which uses the [Tinkerpop modern dataset](https://tinkerpop.apache.org/docs/current/tutorials/the-gremlin-console/#toy-graphs),
can be found under the `modern-example` directory which features an Accumulo
store as its storage backing.

## Federation Example

A demo/example of using Gaffer REST with a Federated Store is available under
the `federated-example` directory.

## Proxy Example

A demo/example of using Gaffer REST with a Proxy Store is available under the
`proxy-example` directory.
