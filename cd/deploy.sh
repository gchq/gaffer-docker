#!/bin/bash

# Copyright 2020 Crown Copyright
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

# Gets project root directory by calling two nested "dirname" commands on the this file
getRootDirectory() {
    echo "$( cd $(dirname $(dirname $0)) > /dev/null 2>&1 && pwd )"
}

# Pushes Tags to Dockerhub
pushTags() {
    name=$1
    version=$2
    app_version=$3
    tags="$(echo ${version} | sed -e "s|\(.*\)\.\(.*\)\..*|${name}:${version}_build.${app_version} ${name}:${version} ${name}:\1.\2 ${name}:\1 ${name}:latest|")"
    IFS=' '
    read -a tagArray <<< "${tags}"
    for tag in "${tagArray[@]}"; do
        docker tag "${name}:${version}" "${tag}"
        docker push "${tag}"
    done
}

# Adds an Chart to a github release 
uploadChart() {
    chart=$1
    version=$2
    token=$3

    helm package "kubernetes/${chart}"
    curl -v -H "Authorization: token $token" -H "Content-Type: application/zip" --data-binary @${chart}-${version}.tar.gz "https://api.github.com/repos/gchq/gaffer-docker/releases/tag/v${version}/assets"
    rm ${chart}-${version}.tar.gz
}

# If branch is not master or is pull request, exit
if [ "${TRAVIS_PULL_REQUEST}" != "false" ] || [ "${TRAVIS_BRANCH}" != "master" ]; then
    exit 0
fi

# Retrieve versions from files
ROOT_DIR="$(getRootDirectory)"
APP_VERSION="$(cat ${ROOT_DIR}/app_version)"

# This set's the values for:
# HADOOP_VERSION
# GAFFER_VERSION
# ACCUMULO_VERSION
source "${ROOT_DIR}"/docker/gaffer/.env

# Log in to Dockerhub
docker login -u "${DOCKER_USERNAME}" -p "${DOCKER_PASSWORD}"

# Push images to Dockerhub
pushTags gchq/hdfs "${HADOOP_VERSION}" "${APP_VERSION}"
pushTags gchq/accumulo "${ACCUMULO_VERSION}" "${APP_VERSION}"
pushTags gchq/gaffer "${GAFFER_VERSION}" "${APP_VERSION}"
pushTags gchq/gaffer-rest "${GAFFER_VERSION}" "${APP_VERSION}"
pushTags gchq/gaffer-road-traffic-loader "${GAFFER_VERSION}" "${APP_VERSION}"
pushTags gchq/gaffer-operation-runner "${GAFFER_VERSION}" "${APP_VERSION}"

# Setup Git Credentials
git config --global credential.helper "store --file=.git/credentials"
echo "https://${GITHUB_TOKEN}:@github.com" > .git/credentials

# Add Develop branch
git remote set-branches --add origin develop gh-pages
git pull

# Tag release in Git
TAG_NAME=v"${APP_VERSION}"
git tag "${TAG_NAME}"
git push origin "${TAG_NAME}"

# Create release notes
REPO_NAME="Gaffer-Docker"
JSON_DATA="{
                \"tag_name\": \"${TAG_NAME}\",
                \"name\": \"${REPO_NAME} ${APP_VERSION}\",
                \"body\": \"[${APP_VERSION} headliners](https://github.com/gchq/${REPO_NAME}/issues?q=milestone%3A${TAG_NAME}+label%3Aheadliner)\n\n[${APP_VERSION} enhancements](https://github.com/gchq/${REPO_NAME}/issues?q=milestone%3A${TAG_NAME}+label%3Aenhancement)\n\n[${APP_VERSION} bugs fixed](https://github.com/gchq/${REPO_NAME}/issues?q=milestone%3A${TAG_NAME}+label%3Abug)\n\n[${APP_VERSION} migration notes](https://github.com/gchq/${REPO_NAME}/issues?q=milestone%3A${TAG_NAME}+label%3Amigration-required)\n\n[${APP_VERSION} all issues resolved](https://github.com/gchq/${REPO_NAME}/issues?q=milestone%3A${TAG_NAME})\",
                \"draft\": false
            }"
echo "${JSON_DATA}"
curl -v --data "${JSON_DATA}" https://api.github.com/repos/gchq/"${REPO_NAME}"/releases?access_token="${GITHUB_TOKEN}"

# Update version on develop
git checkout develop
./cd/update_app_version.sh
git commit -a -m "Updated App version"
git push

# Upload Charts to Github releases
uploadChart gaffer "${APP_VERSION}" "${GITHUB_TOKEN}"
uploadChart gaffer-road-traffic "${APP_VERSION}" "${GITHUB_TOKEN}"
uploadChart hdfs "${APP_VERSION}" "${GITHUB_TOKEN}"

# Build index.yaml file
git checkout gh-pages
git merge master -m "Updated docs to latest version"
helm repo index . --url "https://github.com/gchq/gaffer-docker/releases/tag/${TAG_NAME}"
git commit -a -m "Updated Repo to ${TAG_NAME}"
git push origin gh-pages
