# Deploying Gaffer on AWS EKS
All scripts listed here are intended to be run from the kubernetes/gaffer folder

First follow the [instructions here](../../docs/aws-eks-deployment.md) to provision and configure an [AWS EKS](https://aws.amazon.com/eks/) cluster that the Gaffer Road Traffic Helm Chart can be deployed on.

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
  EXTRA_HELM_ARGS+="--set gaffer.hdfs.namenode.repository=${REPO_PREFIX}/hdfs "
  EXTRA_HELM_ARGS+="--set gaffer.hdfs.datanode.repository=${REPO_PREFIX}/hdfs "
  EXTRA_HELM_ARGS+="--set gaffer.hdfs.shell.repository=${REPO_PREFIX}/hdfs "
  EXTRA_HELM_ARGS+="--set gaffer.accumulo.image.repository=${REPO_PREFIX}/gaffer "
  EXTRA_HELM_ARGS+="--set gaffer.api.image.repository=${REPO_PREFIX}/gaffer-rest "
  EXTRA_HELM_ARGS+="--set gaffer.ui.image.repository=${REPO_PREFIX}/gaffer-ui "
  EXTRA_HELM_ARGS+="--set loader.image.repository=${REPO_PREFIX}/gaffer-road-traffic-loader "
fi
```

## Deploy Helm Chart

By default the gaffer graph uses the in-memory MapStore. If you want to use an alternative store, we have a guide for that [here](../../docs/deploy-empty-graph.md)


```bash
export HADOOP_VERSION=${HADOOP_VERSION:-3.2.1}
export GAFFER_VERSION=${GAFFER_VERSION:-1.21.1}
export GAFFER_TOOLS_VERSION=${GAFFER_TOOLS_VERSION:-1.21.1}

helm dependency update ../accumulo/
helm dependency update ../gaffer/
helm dependency update

helm install gaffer . -f ./values-eks-alb.yaml \
  ${EXTRA_HELM_ARGS} \
  --set gaffer.accumulo.hdfs.namenode.tag=${HADOOP_VERSION} \
  --set gaffer.accumulo.hdfs.datanode.tag=${HADOOP_VERSION} \
  --set gaffer.accumulo.hdfs.shell.tag=${HADOOP_VERSION} \
  --set gaffer.accumulo.image.tag=${GAFFER_VERSION} \
  --set gaffer.api.image.tag=${GAFFER_VERSION} \
  --set gaffer.ui.image.tag=${GAFFER_TOOLS_VERSION} \
  --set loader.image.tag=${GAFFER_VERSION}

helm test road-traffic
```
