#!/usr/bin/env bash
export SPARK_DIST_CLASSPATH=$(hadoop classpath)
export PYSPARK_DRIVER_PYTHON=python3
export PYSPARK_PYTHON=python3
