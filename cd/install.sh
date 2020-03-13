#!/bin/bash
set -e
# if [ ${TRAVIS_PULL_REQUEST} != 'true' ]; then
#     exit 0
# fi

# Create a cluster 
kind create cluster -q

kubectl get pods --namespace=kube-system

# Build images
cd docker/hdfs
docker-compose build
cd ../..

# Deploy HDFS
cd kubernetes/hdfs
kind load docker-image gchq/hdfs:3.2.1
helm install hdfs . --wait

# Deploy Accumulo
# TODO

# Deploy Gaffer REST service
# TODO