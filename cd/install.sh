#!/bin/bash
set -e

# Lint Helm Charts
for chart in ./kubernetes/*; do
    flags=''
    [ ! -f "${chart}/values-insecure.yaml" ] || flags="-f ${chart}/values-insecure.yaml"

    helm dependency update ${chart}
    helm lint ${flags} ${chart}
    helm template test ${flags} ${chart} >/dev/null
done

if [ ${TRAVIS_PULL_REQUEST} == 'false' ]; then
    exit 0
fi

# Create a cluster 
kind create cluster --quiet

cd kubernetes/gaffer
# Build images
docker-compose --project-directory ../../docker/accumulo/ -f ../../docker/accumulo/docker-compose.yaml build
docker-compose --project-directory ../../docker/gaffer/ -f ../../docker/gaffer/docker-compose.yaml build

# Deploy Images to Kind
kind load docker-image gchq/hdfs:3.2.1
kind load docker-image gchq/gaffer:1.11.0
kind load docker-image gchq/gaffer-wildfly:1.11.0

# Deploy containers onto Kind
# Travis needs this setting to avoid reverse dns lookup errors
echo "Starting helm install"
helm install gaffer . -f ./values-insecure.yaml --set hdfs.config.hdfsSite."dfs\.namenode\.datanode\.registration\.ip-hostname-check"=false
