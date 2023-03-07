Docker
=======

In this directory you can find the Dockerfiles and docker compose files for building container images for:
* [Gaffer](gaffer/)
* Gaffer's [REST API](gaffer-rest/)
* Gaffer's [Web UI](gaffer-ui/)
* Gaffer's [Road Traffic Data Loader](gaffer-road-traffic-loader/) 
* [HDFS](hdfs/)
* [Accumulo](accumulo/)
* Gaffer [Integration Test Runner](gaffer-integration-tests/)
* [gafferpy Jupyter Notebook](gaffer-pyspark-notebook/)
* Gaffer [options server for JupyterHub](gaffer-jhub-options-server/)
* [Spark](spark-py/)

For more specific information on what these images are for and how to build them, please see their respective READMEs.

Please note that some of these containers will only be useful if utilised by the Helm Charts under [Kubernetes](/kubernetes/), and may not be possible to run on their own.

# Requirements
Before you can build and run these containers you will need to install Docker along with the compose plugin. Information on this can be found in the docker docs
* [Installing docker](https://docs.docker.com/get-docker/)
