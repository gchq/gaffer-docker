Gaffer with Kerberos
======
This folder contains images which build on those in the parent directory to use Kerberos for authentication.
There's also an extra Dockerfile and image to implement a Kerberos KDC.

# Building
You can build the images using docker-compose:

```bash
docker-compose build
```

# Running

```
docker-compose up
```

Access the HDFS NameNode web UI at: http://localhost:9870

Access the Accumulo Monitor UI at: http://localhost:9995

Access the Gaffer Web UI at: http://localhost:5000/ui/

Access the Gaffer REST API at: http://localhost:8080/rest/