#!/bin/bash
set -e
if [ ${TRAVIS_PULL_REQUEST} != 'true' ]; then
    exit 0
fi

# Create a cluster 
minikube start --vm-driver=none --kubernetes-version=${KUBERNETES_VERSION}
minikube update-context

# Build images
cd docker/hdfs
docker-compose build
cd ../..

# Deploy HDFS
cd kubernetes/hdfs
minikube cache add gchq/hdfs:3.2.1
# Travis needs this to avoid reverse dns lookup errors
helm install hdfs . --set config.hdfsSite."dfs\.namenode\.datanode\.registration\.ip-hostname-check"=false --wait

# Deploy Accumulo
# TODO

# Deploy Gaffer REST service
# TODO