# Gaffer Docker

This repo contains the code needed to run Gaffer using Docker or Kubernetes.
There are two main sub-folders, 'docker' and 'kubernetes', which contain the
project files you need for starting Gaffer using those services.

## Running Gaffer Using Docker

For information on how to run Gaffer using Docker containers please see the
documentation: [Gaffer Docker Docs](https://gchq.github.io/gaffer-doc/latest/administration-guide/gaffer-deployment/gaffer-docker/gaffer-images.html)

We also provide some example deployments with different store backings
to help you get started learning and testing Gaffer. Please see the
[example deployments](./docker/example-deployments/) directory for more
details.

## Running Gaffer Using Kubernetes

For information on how to run Gaffer using Kubernetes, please see the
documentation: [Gaffer Kubernetes Docs](https://gchq.github.io/gaffer-doc/latest/administration-guide/gaffer-deployment/kubernetes-guide/running-on-kubernetes.html)

## Versioning

Each of the released images will be tagged with the version of the
software they represent. Every release we update the `latest` tag for each
image and add a new release which has the corresponding version tag.

If we release Gaffer version 2.1.2, the following images would be uploaded:

- gchq/gaffer:latest
- gchq/gaffer:2
- gchq/gaffer:2.1
- gchq/gaffer:2.1.2
- gchq/gaffer:2.1.2-accumulo-2.0.1

We maintain mutable versions of latest, as well as the major, minor and bugfix
versions of Gaffer. For reproducibility make sure to use the full version in
your build metadata. For `gaffer`/`gaffer-rest` images, we also create a tag
including the accumulo version, this allows for compatibility with Accumulo
1.9.3 in our tests. The `-accumulo-1.9.3` tagged images are not published but
can be built locally if required.

The release process is automated by GitHub actions.

## Known Compatible Docker Versions

- 20.10.23

## Contributing

We welcome contributions to this project. Detailed information on our ways of
working can be found in our [developer docs](https://gchq.github.io/gaffer-doc/latest/development-guide/ways-of-working.html).
