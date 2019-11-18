#!/bin/bash
GAFFER_VERSION=1.10.2

docker build --build-arg gaffer_version=$GAFFER_VERSION ./docker/gaffer-wildfly --tag=gaffer-wildfly
