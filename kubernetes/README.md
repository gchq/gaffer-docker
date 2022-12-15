Kubernetes
==========
In this directory you can find the Helm charts required to deploy various applications onto Kubernetes clusters. 
The Helm charts and associated information for each application can be found in the following places: 
* [HDFS](kubernetes/hdfs/)
* [Accumulo](kubernetes/accumulo/)
* [Gaffer](kubernetes/gaffer/)
* [Example Gaffer Graph containing Road Traffic Dataset](kubernetes/gaffer-road-traffic/)
* [JupyterHub with Gaffer integrations](kubernetes/gaffer-jhub/)

These charts can be accessed by cloning our repository or by using our Helm repo hosted on our [GitHub Pages Site](https://gchq.github.io/gaffer-docker)


## Adding this repo to Helm
To add the gaffer-docker repo to helm run:
```bash
helm repo add gaffer-docker https://gchq.github.io/gaffer-docker
```

# Kubernetes How-to Guides
We have a number of [guides](./docs/guides.md) to help you deploy Gaffer on Kubernetes. It is important you look at these before you get started, they provide the initial steps for running these applications.

# Requirements
Before you can deploy any of these applications you need to have installed Kubernetes.
* [Installing Kubernetes](https://kubernetes.io/docs/setup/)

You will also need to install Docker and docker-compose.
* [installing docker](https://docs.docker.com/get-docker/)
* [installing docker-compose](https://docs.docker.com/compose/install/)
