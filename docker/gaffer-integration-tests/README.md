Gaffer Integration Tests
==========================

This image contains and runs the Accumulo integration tests against an Accumulo cluster.
To run it you need to provide the store properties at /tests/conf/store.properties.

Values from these will be copied accross to the src/tests/resources store properties and will be used by the tests

To Build the Docker image, use:
```bash
docker build -t gchq/gaffer-integration-tests:1.15.0 .
```

If you want to build a different branch or release version, you can provide a build arg:
```bash
docker build -t gchq/gaffer-integration-tests:develop . --build-arg GAFFER_VERSION=develop
```