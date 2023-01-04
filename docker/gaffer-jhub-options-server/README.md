Gaffer Options Server for JupyterHub
====================================
This folder contains the files required to create a JupyterHub Options Server. This is used by Helm and will not work properly without being run using the helm charts in [kubernetes/gaffer-jhub](../../kubernetes/gaffer-jhub/).

This 'options server' works in cooperation with JupyterHub to allow pre-configured notebook instances to be provisioned for users so that they can easily interact with HDFS and Gaffer instances.

It connects to a Kubernetes API and monitors the cluster for any:
* deployed [HDFS](../../kubernetes/hdfs/) Helm chart instances
* deployed [Gaffer](../../kubernetes/gaffer/) Helm chart instances
* Kubernetes service accounts that can be assigned to notebook pods

A JupyterHub instance, using a [custom KubeSpawner](../../kubernetes/gaffer-jhub/files/hub/config.py), can make a HTTP call to `/options` to retrieve HTML that it can use to display a form that allows users to specify:
* notebook container image
* HDFS instance they want to interact with
* Gaffer instance they want to query
* cpu and mem resources that should be allocated to the notebook pod
* cpu and mem resources that should be allocated to Spark executor pods
* Kubernetes namespace the notebook pod should be deployed into
* storage volume
* Kubernetes service account and AWS IAM role (if the Kubernetes cluster is using [IAM roles for service accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) to be attached to the notebook

Once the user has completed the form, the custom KubeSpawner should submit their choices to `/prespawn`. The options server will then provision any required resources (e.g. a ConfigMap containing Hadoop configuration) and return additional configuration that should be applied to the notebook pod, such as:
* resource requests and/or limits to set
* extra environment variables
* additional ConfigMaps and Secrets to mount

## Running Locally
If you do want to run these containers using Docker you can, by running the following from this directory:
```bash
docker-compose up
```