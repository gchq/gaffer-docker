#!/bin/bash
set -e
# if [ ${TRAVIS_PULL_REQUEST} != 'true' ]; then
#     exit 0
# fi

# Create a cluster 
minikube start --vm-driver=none --kubernetes-version=${KUBERNETES_VERSION} --extra-config=kubelet.cluster-domain="default.svc.cluster.local svc.cluster.local cluster.local localdomain"
minikube update-context

# Build images
cd docker/hdfs
docker-compose build
cd ../..

# Deploy HDFS
cd kubernetes/hdfs
minikube cache add gchq/hdfs:3.2.1
helm install hdfs . --wait

# Deploy Accumulo
# TODO

# Deploy Gaffer REST service
# TODO