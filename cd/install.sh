#!/bin/bash
set -e

buildImages() {
    docker-compose --project-directory ../../docker/accumulo/ -f ../../docker/accumulo/docker-compose.yaml build
    docker-compose --project-directory ../../docker/gaffer-road-traffic-loader/ -f ../../docker/gaffer-road-traffic-loader/docker-compose.yaml build
}

# Lint Helm Charts
for chart in ./kubernetes/*; do
    flags=''
    [ ! -f "${chart}/values-insecure.yaml" ] || flags="-f ${chart}/values-insecure.yaml"

    helm dependency update ${chart}
    helm lint ${flags} ${chart}
    helm template test ${flags} ${chart} >/dev/null
done

cd kubernetes/gaffer-road-traffic

if [ ${TRAVIS_PULL_REQUEST} == 'false' ]; then
    if [ "${TRAVIS_BRANCH}" == "master"]; then
        # Build images so they can be pushed later
        buildImages
    fi
    exit 0
fi

# Create a cluster 
kind create cluster --quiet

buildImages

# Deploy Images to Kind
kind load docker-image gchq/hdfs:3.2.1
kind load docker-image gchq/gaffer:1.11.0
kind load docker-image gchq/gaffer-rest:1.11.0
kind load docker-image gchq/gaffer-road-traffic-loader:1.11.0

# Deploy containers onto Kind
# Travis needs this setting to avoid reverse dns lookup errors
echo "Starting helm install"
helm install gaffer . -f ./values-insecure.yaml --set gaffer.hdfs.config.hdfsSite."dfs\.namenode\.datanode\.registration\.ip-hostname-check"=false
