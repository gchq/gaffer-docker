#!/bin/bash
set -e

# Install Kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBERNETES_VERSION}/bin/linux/amd64/kubectl
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

# Install Helm
curl -Lo ./helm.tar.gz https://get.helm.sh/helm-v3.1.1-linux-amd64.tar.gz
tar -zxvf helm.tar.gz
sudo mv linux-amd64/helm /usr/local/bin/

if [ ${TRAVIS_PULL_REQUEST} == 'false' ]; then
    exit 0
fi

# Install Kind
curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.7.0/kind-$(uname)-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
