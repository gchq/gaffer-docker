#!/bin/bash
set -e
# Build images
cd docker/hdfs
docker-compose build
cd ../..

# Deploy HDFS
cd kubernetes/hdfs
kind load docker-image gchq/hdfs:3.2.1
helm install hdfs .

# Wait for pod deployment
while [[ $(kubectl get pods hdfs-datanode-2 -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do 
    echo "waiting for pod" 
    && sleep 5; 
done

# Delete datanode to get around dodgy hdfs namenode issue
kubectl delete pod hdfs-datanode-0 hdfs-datanode-1 hdfs-datanode-2

# Deploy Accumulo
# TODO

# Deploy Gaffer REST service
# TODO