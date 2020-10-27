Adding your own libraries and functions
=======================================
By default with the Gaffer deployment you get access to the:
* Sketches library
* JCS cache library

If you want more libraries than this (either one of ours of one of your own) you'll need to customise the docker images and use them in place of the defaults.

You'll need a basic Gaffer instance deployed on Kubernetes. Here's [how to do that](./deploy-empty-graph.md).

### Overwrite the REST war file
At the moment, Gaffer uses a WAR file with all the dependencies bundled in. You'll need to extend the WAR file using [these instructions](https://gchq.github.io/gaffer-doc/components/rest-api.html#how-to-modify-the-rest-api-for-your-project). Once you have a custom war file, you'll need to create a new image based on the `gaffer-rest` one. To do that you'll need a `Dockerfile` like this one:
```Dockerfile
FROM gchq/gaffer-rest:latest
COPY ./my-custom-rest:1.0-SNAPSHOT.war /opt/jboss/wildfly/standalone/deployments/rest.war
```

Build the image using:
```bash
docker build -t custom-rest:latest .
```

### Add the extra libraries to the Accumulo image
Gaffer's accumulo image includes support for the following gaffer libraries:
* The Bitmap Library
* The Sketches Library
* The Time Library

In order to push down any extra value objects and filters to Accumulo that aren't in those libraries, we have to add the jars to the accumulo /lib/ext directory. Here's an example `Dockerfile`:
```Dockerfile
FROM gchq/gaffer:latest
COPY ./my-library-1.0-SNAPSHOT.jar /opt/accumulo/lib/ext
```
Then build the image
```bash
docker build -t custom-gaffer-accumulo:latest .
```

### Switch the images in the deployment

You'll need a way of making the custom images visible to the kubernetes cluster. With EKS, you can do this by uploading the images to ECR. There's an example for how to do that in one of our [other guides](./aws-eks-deployment.md#Container+Images). With KinD, you just run `kind load docker-image <image:tag>`.

Once visible you can switch them out. Create a `custom-images.yaml` file with the following contents:
```yaml
api:
  image:
    repository: custom-rest
    tag: latest

accumulo:
  image:
    repository: custom-gaffer-accumulo
    tag: latest
```

To switch them run:
```bash
helm upgrade my-graph gaffer-docker/gaffer -f custom-images.yaml --reuse-values
```

### What next?
See our [guides](./guides.md) for other things you can do with Gaffer on Kubernetes.
