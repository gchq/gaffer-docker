#!/bin/bash
# set -e
# if [ ${TRAVIS_PULL_REQUEST} != 'true' ]; then
#     exit 0
# fi
# Run tests
cd kubernetes/hdfs
helm test hdfs

kubectl logs hdfs-namenode-0

echo "Getting DNS logs"

for p in $(kubectl get pods --namespace=kube-system -l k8s-app=kube-dns -o name); do kubectl logs --namespace=kube-system $p; done

echo "Doing DNS lookup"

kubectl exec hdfs-namenode-0 -- bash -c "ip=$(dig +short +search hdfs-datanode-0.hdfs-datanodes) && echo ${dig} && dig +search -b ${ip}"

echo "Getting dns settings"

kubectl exec hdfs-namenode-0 cat /etc/resolv.conf
