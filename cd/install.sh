#!/bin/bash
set -e
# if [ ${TRAVIS_PULL_REQUEST} != 'true' ]; then
#     exit 0
# fi

# Create a cluster 
kind create cluster -q

# Build images
cd docker/hdfs
docker-compose build
cd ../..

# Deploy HDFS
cd kubernetes/hdfs
kind load docker-image gchq/hdfs:3.2.1
helm install hdfs .

# Wait for pod deployment
kubectl wait --for=condition=Ready pods/hdfs-datanode-0 pods/hdfs-datanode-1 pods/hdfs-datanode-2 pods/hdfs-namenode-0

# Delete datanode to get around dodgy hdfs namenode issue
kubectl delete pod hdfs-datanode-0 hdfs-datanode-1 hdfs-datanode-2

# Wait for pod redeployment
kubectl wait --for=condition=Ready pods/hdfs-datanode-0 pods/hdfs-datanode-1 pods/hdfs-datanode-2

# Deploy Accumulo
# TODO

# Deploy Gaffer REST service
# TODO