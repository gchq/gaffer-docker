#!/bin/bash
set -e
# if [ ${TRAVIS_PULL_REQUEST} != 'true' ]; then
#     exit 0
# fi

# Create a cluster 
minikube start --vm-driver=none --kubernetes-version=${KUBERNETES_VERSION} --extra-config=kubelet.resolv-conf=""
minikube update-context

# Build images
cd docker/hdfs
docker-compose build
cd ../..

# Make sure kubernetes is ready
JSONPATH='{range .items[*]}{@.metadata.name}:{range @.status.conditions[*]}{@.type}={@.status};{end}{end}'; \
    until kubectl get nodes -o jsonpath="$JSONPATH" 2>&1 | grep -q "Ready=True"; do sleep 1; done

# Deploy HDFS
cd kubernetes/hdfs
minikube cache add gchq/hdfs:3.2.1
helm install hdfs . --wait

# Deploy Accumulo
# TODO

# Deploy Gaffer REST service
# TODO