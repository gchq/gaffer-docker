Copyright 2016 Crown Copyright, cybermaggedon

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

----

Here's some template configuration files to run Gaffer on Kubernetes
in the Google cloud.  This template uses three ext4 disks in the cloud, the
configuration on AWS is slightly different.

```

  a=https://www.googleapis.com/auth
  proj=MY-PROJECT

  # Create cluster
  gcloud container --project ${proj} clusters create gaffer-cluster \
    --zone "us-east1-b" --machine-type "n1-standard-4" \
    --scopes "${a}/compute","${a}/devstorage.read_only","${a}/logging.write","${a}/monitoring","${a}/servicecontrol","${a}/service.management.readonly" \
    --num-nodes 3 --network "default" --enable-cloud-logging \
    --enable-cloud-monitoring


  # 25 GB disk for Gaffer Hadoop
  gcloud compute --project ${proj} disks create "hadoop-0000" \
  --size "25" --zone "us-east1-b" --type "pd-standard"

  # 10 GB disk for Gaffer Zookeeper
  gcloud compute --project ${proj} disks create "zookeeper-0000" \
  --size "10" --zone "us-east1-b" --type "pd-standard"

  # 1 GB disk for Gaffer Accumulo
  gcloud compute --project ${proj} disks create "accumulo-0000" \
      --size "1" --zone "us-east1-b" --type "pd-standard"

  # Get Kubernetes creds
  gcloud container clusters get-credentials gaffer-cluster \
      --zone us-east1-b --project ${proj}

  # Deploy
  kubectl apply -f gaffer-deployment.yaml
  kubectl apply -f gaffer-services.yaml

```

