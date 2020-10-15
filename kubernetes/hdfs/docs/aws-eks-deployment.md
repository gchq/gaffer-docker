# Deploying HDFS on AWS EKS
All scripts listed here are intended to be run from the kubernetes/hdfs folder

First follow the [instructions here](../../docs/aws-eks-deployment.md) to provision and configure an [AWS EKS](https://aws.amazon.com/eks/) cluster that the HDFS Helm Chart can be deployed on.

## Using ECR
If you are hosting the container images in your AWS account, using ECR, then run the following commands to configure the Helm Chart to use them:

```bash
ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
[ "${REGION}" = "" ] && REGION=$(aws configure get region)
[ "${REGION}" = "" ] && REGION=$(curl --silent -m 5 http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | cut -d'"' -f 4)
if [ "${REGION}" = "" ]; then
  echo "Unable to detect AWS region, please set \$REGION"
else
  REPO_PREFIX="${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/gchq"

  EXTRA_HELM_ARGS=""
  EXTRA_HELM_ARGS+="--set namenode.repository=${REPO_PREFIX}/hdfs "
  EXTRA_HELM_ARGS+="--set datanode.repository=${REPO_PREFIX}/hdfs "
  EXTRA_HELM_ARGS+="--set shell.repository=${REPO_PREFIX}/hdfs "
fi
```

## Deploy Helm chart

```bash
export HADOOP_VERSION=${HADOOP_VERSION:-3.2.1}

helm install hdfs . -f ./values-eks-alb.yaml \
  ${EXTRA_HELM_ARGS} \
  --set hdfs.namenode.tag=${HADOOP_VERSION} \
  --set hdfs.datanode.tag=${HADOOP_VERSION} \
  --set hdfs.shell.tag=${HADOOP_VERSION}

helm test hdfs
```
