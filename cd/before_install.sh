#!/bin/bash
set -e
# Install Kubectl
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x kubectl
mv kubectl /usr/bin/

# Install Kind
curl -Lo ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.7.0/kind-$(uname)-amd64
chmod +x ./kind
mv kind /usr/bin/

# Install Helm
curl -Lo ./helm.tar.gz https://get.helm.sh/helm-v3.1.1-linux-amd64.tar.gz
tar -zxvf helm.tar.gz
mv linux-amd64/helm /usr/bin/

# Create a cluster 
kind create cluster