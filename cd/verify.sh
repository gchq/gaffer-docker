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

kubectl exec hdfs-namenode-0 -- bash -c "ip=\$(dig +short +search hdfs-datanode-0.hdfs-datanodes | head -1) && echo \${ip} && dig +search -x \${ip}"

echo "Getting dns settings"

kubectl exec hdfs-namenode-0 cat /etc/resolv.conf

echo "Getting /etc/hosts on the namenode"

kubectl exec hdfs-namenode-0 cat /etc/hosts

echo "Getting /etc/hosts on the datanode (0)"

kubectl exec hdfs-datanode-0 cat /etc/hosts
