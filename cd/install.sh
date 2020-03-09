#!/bin/bash

# Build images
cd docker/hdfs && docker-compose build

# Deploy HDFS
cd kubernetes/hdfs
kind load docker-image gchq/hdfs:3.2.1
helm install hdfs .
kubectl port-forward svc/hdfs-namenodes 8080:80

# Deploy Accumulo
# TODO

# Deploy Gaffer REST service
# TODO