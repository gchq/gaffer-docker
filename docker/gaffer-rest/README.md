Gaffer REST
===========
In this folder you can find the required files for building and running Gaffer REST image for the REST API for Gaffer.

# Configuration
The image is based off Gaffer's spring-rest module. It runs a Gaffer REST API using a few different files.

### store.properties: 
The store properties file tells Gaffer how to store its data. You have to provide a store class and store properties class. 
To keep this image small, the only store that is supported is the MapStore which is an in-memory store. A default is provided
in /gaffer/store/store.properties

### schema.json
The Schema files make up a Gaffer schema which tells Gaffer what datasets are stored in your graph. It contains type information
which a store may use to serialise and aggregate the data. You can put the whole schema in one file or split it up into as many
as you choose. A basic schema is provided in /gaffer/schema by default

### graphConfig.json
The Graph config tells Gaffer what the graph is called as well as any hooks to run before an operation chain is run. A default
is provided at /gaffer/graph/graphConfig.json

### application.properties
This is a spring concept and is used to change the context root and any properties related to Gaffer or the app. A default is
provided at /gaffer/config/application.properties

# Running Locally
The easiest way to build and run these services is to use docker compose, by running the following from this directory:
```bash
docker compose up
```

## Customising your builds
We provide the options to build using an official release, a branch or a custom runnable rest.jar file
The order it will check is:

1. Custom "rest.jar" file stored in "/jars"
2. official release
3. branch

To use a release or branch, set the GAFFER_VERSION property in env before running the `docker compose build` command.

We also provide the option to include custom libraries in the /jars/lib directory. These will be added to the classpath
at runtime.

## Containers that are started:
* Gaffer REST

Access the Gaffer REST API at: http://localhost:8080/rest/
