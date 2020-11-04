#!/bin/bash

set -e

root_directory="$( cd $(dirname $(dirname $0)) > /dev/null 2>&1 && pwd )"
cd $root_directory

docker-compose --project-directory ./docker/accumulo/ -f ./docker/accumulo/docker-compose.yaml build
docker-compose --project-directory ./docker/gaffer-operation-runner/ -f ./docker/gaffer-operation-runner/docker-compose.yaml build
