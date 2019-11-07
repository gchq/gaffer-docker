#!/bin/bash

CWD=`pwd`

docker run -p 8080:8080 -v $CWD/example/schema:/schema -it gaffer-wildfly