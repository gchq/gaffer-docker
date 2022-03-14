# spark-py

Designed to be used as the executor container image for [Spark's official Kubernetes support](http://spark.apache.org/docs/latest/running-on-kubernetes.html).

To use this image, update your Spark configuration (e.g. `spark-defaults.conf`) to include:

```
spark.kubernetes.container.image gchq/spark-py:latest
```
