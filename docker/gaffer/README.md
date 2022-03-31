Gaffer
======
The Docker image here is actually an Accumulo image with the Gaffer iterators bundled in. 
When run with docker-compose though, it will provide you a full accumulo ecosystem complete
with [hdfs](../hdfs) and a [Gaffer REST API](../gaffer-rest)

# Building
You can build the gchq/gaffer image using docker-compose:

```bash
docker-compose build
```

## Customising the build

To add your own libraries into the build, you can add files to the /files directory these will be added
to accumulo's /opt/accumulo/lib/ext directory

# Running

```
docker-compose up
```

Access the HDFS NameNode web UI at: http://localhost:9870

Access the Accumulo Monitor UI at: http://localhost:9995

Access the Gaffer Web UI at: http://localhost:5000/ui/

Access the Gaffer REST API at: http://localhost:8080/rest/
