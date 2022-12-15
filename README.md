Gaffer Docker
================

This repo contains the code needed to run Gaffer using Docker or Kubernetes. 
There are two main sub-folders, 'docker' and 'Kubernetes' which contain the project files you need for starting Gaffer using those services.

## Running Gaffer Using Docker
For information on how to run Gaffer using Docker containers, please see the README in the docker directory: [Gaffer Docker README](docker/README.md)

## Running Gaffer Using Kubernetes
For information on how to run Gaffer using Kubernetes, please see the README in the kubernetes directory: [Kubernetes README](kubernetes/README.md)

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

This process is automated by GitHub actions.

## Known Compatible Docker Versions
* 20.10.5

## Contributing
If you would like to make a Contribution, we have all the details for doing that [here](CONTRIBUTING.md)
