#!/bin/bash

set -e

# Gets project root directory by calling two nested "dirname" commands on the this file 
getRootDirectory() {
    echo "$( cd "$(dirname "$(dirname ${BASH_SOURCE[0]})")" > /dev/null 2>&1 && pwd )"
}

# Pushes Tags to Dockerhub
pushTags() {
    name=$1
    version=$2
    app_version=$3

    tags="$(echo ${version} | sed -e "s/\(.*\)\.\(.*\)\..*/"${name}":"${version}"+"${app_version}" "${name}":"${version}" "${name}":\1.\2 "${name}":\1 "${name}":latest/")"

    docker tag ${name} ${tags}
    docker push ${tags}
}

# If branch is not master or is pull request, exit
if [ "${TRAVIS_PULL_REQUEST}" != "false"] || [ "${TRAVIS_BRANCH}" != "master" ]; then
    exit 0
fi

# Retrieve versions from files
ROOT_DIR="$(getRootDirectory)"
APP_VERSION="$(cat ${ROOT_DIR}/app_version)"

# This set's the values for:
# HADOOP_VERSION
# GAFFER_VERSION
# ACCUMULO_VERSION
source ${ROOT_DIR}/docker/gaffer/.env

# Log in to Dockerhub
docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}"

# Push images to Dockerhub
# HDFS
pushTags gchq/hdfs "${HADOOP_VERSION}" "${APP_VERSION}"
# Accumulo
pushTags gchq/accumulo "${ACCUMULO_VERSION}" "${APP_VERSION}"
# Gaffer
pushTags gchq/gaffer "${GAFFER_VERSION}" "${APP_VERSION}"
# Gaffer Wildfly
pushTags gchq/gaffer-wildfly "${GAFFER_VERSION}" "${APP_VERSION}"

# Tag release in Git
TAG_NAME=v"${APP_VERSION}"
git tag "${TAG_NAME}"
git push origin "${TAG_NAME}"

# Update version on develop
git checkout develop
./cd/update_app_version.sh
git commit -a -m "Updated App version"
git push