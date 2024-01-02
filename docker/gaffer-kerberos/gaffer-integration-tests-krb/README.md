Gaffer Kerberos Integration Tests
=================================
This folder contains a Dockerfile for running integration tests against an Accumulo cluster which uses Kerberos authentication.

For more information on the integration tests, please see the primary Gaffer Docker integration tests README.

# Prerequisites
For the HDFS tests to work, you must acquire and place the HDFS native libraries into the `native` directory.
You must also have built the Gaffer with Kerberos containers in the directory above and the non-kerberos
version of the integration tests container image. 

# Running Locally
These services can be built and run using docker compose:
```bash
docker compose up
```

# Issues
HDFS tests fail with Accumulo 2.0.0. They pass with Accumulo 1.9.3. This problem has been raised as [Gaffer issue #3134](https://github.com/gchq/Gaffer/issues/3134).