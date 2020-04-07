This repo contains Dockerfiles for building container images for:
* [HDFS](docker/hdfs/)
* [Accumulo](docker/accumulo/)
* [Gaffer](docker/gaffer/)
* Gaffer's [REST API and Web UI](docker/gaffer-wildfly/)
* Gaffer's [Road Traffic Data Loader](docker/gaffer-road-traffic-loader/)

It also contains Helm Charts so that the following applications can be deployed onto Kubernetes clusters:
* [HDFS](kubernetes/hdfs/)
* [Gaffer](kubernetes/gaffer/)
* [Example Gaffer Graph containing Road Traffic Dataset](kubernetes/gaffer-road-traffic/)

## Contributing

If you would like to make a Contribution, we have all the details for doing that [here](CONTRIBUTING.md)