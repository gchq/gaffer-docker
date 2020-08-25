 Gaffer Docker
================

This repo contains Dockerfiles for building container images for:
* [HDFS](docker/hdfs/)
* [Accumulo](docker/accumulo/)
* [Gaffer](docker/gaffer/)
* Gaffer's [REST API and Web UI](docker/gaffer-rest/)
* Gaffer's [Road Traffic Data Loader](docker/gaffer-road-traffic-loader/)
* Gaffer's [Operation Runner](docker/gaffer-operation-runner/)

It also contains Helm Charts so that the following applications can be deployed onto Kubernetes clusters:
* [HDFS](kubernetes/hdfs/)
* [Gaffer](kubernetes/gaffer/)
* [Example Gaffer Graph containing Road Traffic Dataset](kubernetes/gaffer-road-traffic/)

These charts can be accessed by cloning our repository or by using our Helm repo hosted on our [Github Pages Site](https://gchq.github.io/gaffer-docker)

To use this repo, run:
```bash
helm repo add gaffer https://gchq.github.io/gaffer-docker
```

There are guides on how to deploy the charts on:
* a local Kubernetes cluster, [using kind (Kubernetes IN Docker)](kubernetes/kind-deployment.md)
* an [AWS EKS cluster](kubernetes/aws-eks-deployment.md)

These guides assume you've cloned the repository and are using the Helm charts contained within. We do also host our Helm Charts index on our Github pages site. You can get access to them by running:
```bash
helm repo add gaffer https://gchq.github.io/gaffer-docker
```

## Versioning
Each of our images will be tagged in DockerHub with the version of the software they represent. Every release,
we update the image for that tag and add a new release which has the corresponding git tag.

So if we tag this code in git as 1.0.0 and publish the resulting gaffer image at gaffer version 1.11.0, the following
images would be pushed to Docker Hub:

* gchq/gaffer:latest
* gchq/gaffer:1
* gchq/gaffer:1.11
* gchq/gaffer:1.11.0
* gchq/gaffer:1.11.0_build.1.0.0

Note that we maintain mutable versions of latest, as well as the major, minor and bugfix versions of Gaffer. If you want to
ensure that your image will never change when doing a pull from docker, make sure to use the version with the git tag in the
build metadata.

This process is automated by Travis CI.

## Contributing

If you would like to make a Contribution, we have all the details for doing that [here](CONTRIBUTING.md)
