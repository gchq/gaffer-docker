
```
docker-compose up
```

Access the HDFS NameNode web UI at: http://localhost:9870

Access the Accumulo Monitor UI at: http://localhost:9995

## Change Accumulo minor version
To update the Accumulo minor version, not only must all the references to the old version be replaced, but the config directories must be renamed to the correct version, and their contents checked. For example: `conf-2.0.1` -> `conf-2.1.0`
