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
    --num-nodes 4 --network "default" --enable-cloud-logging \
    --enable-cloud-monitoring

  # Three times 250 GB SSD disks for Gaffer Hadoop
  gcloud compute --project ${proj} disks create "hadoop-0000" \
  --size "250" --zone "us-east1-b" --type "pd-ssd"
  gcloud compute --project ${proj} disks create "hadoop-0001" \
  --size "250" --zone "us-east1-b" --type "pd-ssd"
  gcloud compute --project ${proj} disks create "hadoop-0002" \
  --size "250" --zone "us-east1-b" --type "pd-ssd"

  # Three times 10 GB disk for Gaffer Zookeeper
  gcloud compute --project ${proj} disks create "zookeeper-1" \
  --size "10" --zone "us-east1-b" --type "pd-ssd"
  gcloud compute --project ${proj} disks create "zookeeper-2" \
  --size "10" --zone "us-east1-b" --type "pd-ssd"
  gcloud compute --project ${proj} disks create "zookeeper-3" \
  --size "10" --zone "us-east1-b" --type "pd-ssd"

  # Get Kubernetes creds
  gcloud container clusters get-credentials gaffer-cluster \
      --zone us-east1-b --project ${proj}

  # Deploy
  kubectl apply -f gaffer-deployment.yaml
  kubectl apply -f gaffer-services.yaml

```

The order in which things start is going to be fairly random.  One thing to
note is that it is possible that all the Accumulo nodes may race ahead and
start before Hadoop is ready.  Hadoop containers will only start once their
volumes have been formatted, whereas Accumulo containers have no volumes.
If this happens, the Accumulo initialisation will fail, and the Accumulos will
sit there waiting for the intiailisation to complete.  If this happens,
delete all of the Accumulo PODs so that they restart, and it will trigger the
initialisation.

Note!  This creates Gaffer as an insecure public service on the internet.
Get to work on the firewall settings.

