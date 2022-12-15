Gaffer Integration Tests
=========================
In this folder you can find the required dockerfile for running integration tests against an Accumulo cluster.
This is used by the [Helm scripts](kubernetes/gaffer/templates/tests/integration/accumulo-tests.yaml), and cannot be used to run the integration tests in Docker alone.

To run it you need to provide the store properties at /tests/conf/store.properties.

Values from these will automatically be copied across to the src/tests/resources store properties and will be used by the tests.

## Building the images
If you do want to build the images you can, by running the following from this directory:
```bash
docker build -t gchq/gaffer-integration-tests:2.0.0-alpha-0.3 .
```

If you want to build a different branch or release version, you can provide a build arg:
```bash
docker build -t gchq/gaffer-integration-tests:develop . --build-arg GAFFER_VERSION=develop
```