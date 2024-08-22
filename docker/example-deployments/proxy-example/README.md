# Proxy Example

## Running

This is an example deployment of Gaffer using a Proxy store. This uses two REST
APIs, one contains the data and is backed by a Map Store and the other is a
Proxy Store configured to forward queries to the Map Store backed REST API.

The example uses the
[Tinkerpop Modern Graph](https://tinkerpop.apache.org/docs/current/tutorials/the-gremlin-console/#toy-graphs)
as its data set to demonstrate basic querying of data.

## Running the Example

To run the example please use the provided start script with an environment file
to specify the image versions e.g. `accumulo2.env`:

```bash
./create-deployment.sh ../../accumulo2.env
```

With the demo deployment the Proxy backed Gaffer REST API will be started on port 8080
and the Map store backed instance on 8081.
