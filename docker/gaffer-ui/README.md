Gaffer UI
==========
In this folder you can find the required files for building and running the Gaffer UI in Docker containers.

The code for the Gaffer UI resides in [Gaffer Tools](https://github.com/gchq/gaffer-tools).

# Running Locally
The easiest way to build and run these services is to use docker-compose, by running the following from this directory:
```bash
docker-compose up
```

## Customising the build
You can provide your own ui.war file by putting it in the wars directory. This will be copied into the image.

## Containers that are started:
* Gaffer REST
* Gaffer UI

Access the Gaffer Web UI at: http://localhost:5000/ui/

Access the Gaffer REST API at: http://localhost:8080/rest/
