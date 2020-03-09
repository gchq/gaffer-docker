#!/bin/bash
# set -e
# if [ ${TRAVIS_PULL_REQUEST} != 'true' ]; then
#     exit 0
# fi
# Run tests
cd kubernetes/hdfs
helm test hdfs

echo "auth test logs"
kubectl logs hdfs-auth-test

echo "hdfs datanode 0 logs"
kubectl logs hdfs-datanode-0

echo "hdfs datanode 1 logs"
kubectl logs hdfs-datanode-1


echo "hdfs datanode 2 logs"
kubectl logs hdfs-datanode-2