#!/bin/bash
set -e
if [ ${TRAVIS_PULL_REQUEST} == 'false' ]; then
    exit 0
fi

# Create a cluster 
minikube start --vm-driver=none --kubernetes-version=${KUBERNETES_VERSION}
minikube update-context

cd kubernetes/gaffer
# Build images
docker-compose --project-directory ../../docker/accumulo/ -f ../../docker/accumulo/docker-compose.yaml build
docker-compose --project-directory ../../docker/gaffer/ -f ../../docker/gaffer/docker-compose.yaml build

# Deploy Images to Minikube
minikube cache add gchq/hdfs:3.2.1
minikube cache add gchq/gaffer:1.11.0
minikube cache add gchq/gaffer-wildfly:1.11.0

# Install any dependencies
helm dependency update

# Deploy containers onto Minikube
# Travis needs this setting to avoid reverse dns lookup errors
helm install gaffer . --set hdfs.config.hdfsSite."dfs\.namenode\.datanode\.registration\.ip-hostname-check"=false --timeout 10m0s --wait