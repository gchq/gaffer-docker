#!/bin/bash
set -e
# if [ ${TRAVIS_PULL_REQUEST} != 'true' ]; then
#     exit 0
# fi
# Install Kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/${KUBERNETES_VERSION}/bin/linux/amd64/kubectl
chmod +x kubectl
mv kubectl /usr/local/bin/

# Install Minikube
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
mv minikube /usr/local/bin/

# Install Helm
curl -Lo ./helm.tar.gz https://get.helm.sh/helm-v3.1.1-linux-amd64.tar.gz
tar -zxvf helm.tar.gz
mv linux-amd64/helm /usr/local/bin/