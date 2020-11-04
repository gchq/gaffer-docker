#!/bin/bash

set -e

cd ./kubernetes/gaffer-road-traffic

kind create cluster --quiet

# Deploy Images to Kind
kind load docker-image gchq/hdfs:3.2.1
kind load docker-image gchq/gaffer:1.13.4
kind load docker-image gchq/gaffer-rest:1.13.4
kind load docker-image gchq/gaffer-road-traffic-loader:1.13.4
kind load docker-image gchq/gaffer-operation-runner:1.13.4

# Deploy containers onto Kind
# Travis needs this setting to avoid reverse dns lookup errors
echo "Starting helm install"
helm install gaffer . -f ./values-insecure.yaml
