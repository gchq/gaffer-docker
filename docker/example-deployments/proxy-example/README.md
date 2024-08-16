# Proxy Example

## Running

To run it from the `proxy-example` directory you'll need to specify the
environment file path:

```bash
docker compose --env-file ../.env up
```

Or to run it from this directory, the compose file path and environment file
path:

```bash
docker compose -f proxy-example/compose.yaml --env-file .env up
```

With this deployment both a standard Gaffer REST API and a Gaffer REST API using
the Proxy Store will be started. Only the port for the Proxy REST endpoint is
exposed, this will forward operations to the standard Gaffer REST Endpoint.
