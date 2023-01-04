JupyterHub with Gaffer integrations
===================================

In this directory you can find the Helm charts required to deploy Gaffer's [JupyterHub Options Server](../../docker/gaffer-jhub-options-server/) alongside the [JupyterHub](https://github.com/jupyterhub/zero-to-jupyterhub-k8s) Chart. 
The 'options server' works in cooperation with Jupyter Hub to allow pre-configured notebook instances to be provisioned for users so that they can easily interact with HDFS and Gaffer instances.

This chart adds the following additional properties to [`jupyterhub.singleuser.profileList`](https://zero-to-jupyterhub.readthedocs.io/en/latest/resources/reference.html#singleuser-profilelist):

| Property | Description | Default |
|----------|-------------|---------|
| `enable_hdfs` | If true, users will be prompted to select which HDFS instance they want to interact with when spawning a new notebook. The options server will provision a ConfigMap, that will be mounted into the notebook pod at `/etc/hadoop/conf`, containing Hadoop configuration files to connect to that instance by default. | `false` |
| `enable_gaffer` | If true, users will be prompted to select which Gaffer instance they want to query when spawning a new notebook. The options server will provision a ConfigMap, that will be mounted into the notebook pod at `/etc/gaffer`, containing the Gaffer configuration files (schema, store properties, graph config) for that instance. | `false` |
| `enable_spark` | If true, the options server will provision a ConfigMap, that will be mounted into the notebook pod at `/opt/spark/conf`, containing Spark configuration that causes Executors to be deployed as Pods inside the Kubernetes cluster. Users will be allowed to specify the amount of resources (cpu, mem) that each Spark executor should request when they are spawning a new notebook. | `false` |
| `spark_image` | Sets the container image to be used for Spark Executors. Required if `enable_spark == true`. | nil |
| `spark_ingress_host` | If set, the options server will provision an Ingress resource for this host that allows external access to the Spark web UI. The value can contain the following template variables: `{{USERNAME}}` `{{SERVERNAME}}` | nil |


# Deployment

There are guides for deploying this chart on:
There are guides for deploying this chart on, they should be read in the following order:
* [Provision and configure a local Kubernetes cluster](../docs/kind-deployment.md)
* [Deploy JupyterHub with Gaffer on a Kubernetes cluster](./docs/kind-deployment.md)


