# Deploying Gaffer on AWS EKS

The following instructions will guide you through provisioning and configuring an [AWS EKS](https://aws.amazon.com/eks/) cluster that our Helm Charts can be deployed on.


## Install CLI Tools

* [docker-compose](https://github.com/docker/compose/releases/latest)
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [helm](https://github.com/helm/helm/releases)
* [aws-cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
* [eksctl](https://github.com/weaveworks/eksctl/releases/latest)


## Container Images

If the versions of the container images you would like to deploy are not available in [Docker Hub](https://hub.docker.com/u/gchq) then you will need to host them in a registry yourself.

The following instructions build all the container images and host them in AWS ECR when run from the ./kubernetes folder:


```bash
export HADOOP_VERSION=${HADOOP_VERSION:-3.2.1}
export GAFFER_VERSION=${GAFFER_VERSION:-1.21.1}
export GAFFER_TOOLS_VERSION=${GAFFER_TOOLS_VERSION:-1.21.1}

docker-compose --project-directory ../docker/accumulo/ -f ../docker/accumulo/docker-compose.yaml build
docker-compose --project-directory ../docker/gaffer-operation-runner/ -f ../docker/gaffer-operation-runner/docker-compose.yaml build 

HADOOP_IMAGES="hdfs"
GAFFER_IMAGES="gaffer gaffer-rest gaffer-road-traffic-loader gaffer-operation-runner"
GAFFER_TOOLS_IMAGES="gaffer-ui"

ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
[ "${REGION}" = "" ] && REGION=$(aws configure get region)
[ "${REGION}" = "" ] && REGION=$(curl --silent -m 5 http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | cut -d'"' -f 4)
REPO_PREFIX="${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com/gchq"

for repo in ${HADOOP_IMAGES} ${GAFFER_IMAGES} ${GAFFER_TOOLS_IMAGES}; do
  aws ecr create-repository --repository-name gchq/${repo}
done

echo $(aws ecr get-login-password) | docker login -u AWS --password-stdin https://${ACCOUNT}.dkr.ecr.${REGION}.amazonaws.com

for repo in ${HADOOP_IMAGES}; do
  docker image tag gchq/${repo}:${HADOOP_VERSION} ${REPO_PREFIX}/${repo}:${HADOOP_VERSION}
  docker image push ${REPO_PREFIX}/${repo}:${HADOOP_VERSION}
done

for repo in ${GAFFER_IMAGES}; do
  docker image tag gchq/${repo}:${GAFFER_VERSION} ${REPO_PREFIX}/${repo}:${GAFFER_VERSION}
  docker image push ${REPO_PREFIX}/${repo}:${GAFFER_VERSION}
done

for repo in ${GAFFER_TOOLS_IMAGES}; do
  docker image tag gchq/${repo}:${GAFFER_TOOLS_VERSION} ${REPO_PREFIX}/${repo}:${GAFFER_TOOLS_VERSION}
  docker image push ${REPO_PREFIX}/${repo}:${GAFFER_TOOLS_VERSION}
done
```

## EKS Cluster

There are a number of ways to provision an AWS EKS cluster. This guide uses a cli tool called `eksctl`. Documentation is available at https://docs.aws.amazon.com/eks/latest/userguide/getting-started.html for some of the other methods.

Before issuing any commands, the subnets that will be used by your EKS cluster need to be tagged accordingly:
| Subnet Type | Tag Key                         | Tag Value |
| ----------- | ------------------------------- | --------- |
| Public      | kubernetes.io/role/elb          | 1         |
| Private     | kubernetes.io/role/internal-elb | 1         |

If you want the cluster to spin up in a VPC that isn't the default, then set `$VPC_ID`.

```bash
EKS_CLUSTER_NAME=${EKS_CLUSTER_NAME:-gaffer}
KUBERNETES_VERSION=${KUBERNETES_VERSION:-1.15}

[ "${VPC_ID}" = "" ] && VPC_ID=$(aws ec2 describe-vpcs --filters Name=isDefault,Values=true --query Vpcs[0].VpcId --output text)
[ "${VPC_ID}" = "" ] && echo "Unable to detect default VPC ID, please set \$VPC_ID" && exit 1

# Obtain a list of public and private subnets that the cluster will be deployed into by querying for the required 'elb' tags
PUBLIC_SUBNET_IDS=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=${VPC_ID} Name=tag-key,Values=kubernetes.io/role/elb --query Subnets[].SubnetId --output text | tr -s '[:blank:]' ',')
PRIVATE_SUBNET_IDS=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=${VPC_ID} Name=tag-key,Values=kubernetes.io/role/internal-elb --query Subnets[].SubnetId --output text | tr -s '[:blank:]' ',')
[ "${PUBLIC_SUBNET_IDS}" = "" ] && echo "Unable to detect any public subnets. Make sure they are tagged: kubernetes.io/role/elb=1" && exit 1
[ "${PRIVATE_SUBNET_IDS}" = "" ] && echo "Unable to detect any private subnets. Make sure they are tagged: kubernetes.io/role/internal-elb=1" && exit 1

eksctl create cluster \
  -n "${EKS_CLUSTER_NAME}" \
  --version "${KUBERNETES_VERSION}" \
  --managed \
  --nodes 3 \
  --nodes-min 3 \
  --nodes-max 12 \
  --node-volume-size 20 \
  --full-ecr-access \
  --alb-ingress-access \
  --vpc-private-subnets "${PRIVATE_SUBNET_IDS}" \
  --vpc-public-subnets "${PUBLIC_SUBNET_IDS}"

aws eks update-kubeconfig --name ${EKS_CLUSTER_NAME}
```


## Ingress

Deploy the AWS ALB Ingress Controller, using the docs at https://docs.aws.amazon.com/eks/latest/userguide/alb-ingress.html

At the time of writing, this involves issuing the following commands:

```bash
EKS_CLUSTER_NAME=${EKS_CLUSTER_NAME:-gaffer}

[ "${ACCOUNT}" = "" ] && ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
[ "${REGION}" = "" ] && REGION=$(aws configure get region)
[ "${REGION}" = "" ] && REGION=$(curl --silent -m 5 http://169.254.169.254/latest/dynamic/instance-identity/document | grep region | cut -d'"' -f 4)
[ "${REGION}" = "" ] && echo "Unable to detect AWS region, please set \$REGION" && exit 1

eksctl utils associate-iam-oidc-provider \
  --region "${REGION}" \
  --cluster "${EKS_CLUSTER_NAME}" \
  --approve

aws iam create-policy \
  --policy-name ALBIngressControllerIAMPolicy \
  --policy-document https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/iam-policy.json

kubectl apply -f https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/rbac-role.yaml

eksctl create iamserviceaccount \
  --region "${REGION}" \
  --name alb-ingress-controller \
  --namespace kube-system \
  --cluster "${EKS_CLUSTER_NAME}" \
  --attach-policy-arn arn:aws:iam::${ACCOUNT}:policy/ALBIngressControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --approve

curl https://raw.githubusercontent.com/kubernetes-sigs/aws-alb-ingress-controller/v1.1.4/docs/examples/alb-ingress-controller.yaml | sed "s/# - --cluster-name=devCluster/- --cluster-name=${EKS_CLUSTER_NAME}/" | kubectl apply -f -
```


## Deploy Helm Charts

* [HDFS](../hdfs/docs/aws-eks-deployment.md)
* [Gaffer](../gaffer/docs/aws-eks-deployment.md)
* [Example Gaffer Graph containing Road Traffic Dataset](../gaffer-road-traffic/docs/aws-eks-deployment.md)


## Access Web UIs

The AWS ALB Ingress Controller will create an application load balancer (ALB) for each Ingress resource deployed into the EKS cluster.

You can find out the URL that you can use to access each ingress with `kubectl get ing`

**⚠️ WARNING ⚠️**\
By default, the security group assigned to the ALBs will allow anyone to access them. We highly recommend attaching a combination of the [other annotations available](https://kubernetes-sigs.github.io/aws-alb-ingress-controller/guide/ingress/annotation/#security-groups) to each of your Ingress resources to control access to them.


## Uninstall

```bash
EKS_CLUSTER_NAME=${EKS_CLUSTER_NAME:-gaffer}

# Use helm to uninstall any deployed charts
for release in $(helm ls --short); do
  helm uninstall ${release}
done

# Ensure EBS volumes are deleted
kubectl get pvc --output name | xargs kubectl delete

# Delete the EKS cluster
eksctl delete cluster --name "${EKS_CLUSTER_NAME}"
```
