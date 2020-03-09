#!/bin/bash
set -e
# if [ ${TRAVIS_PULL_REQUEST} != 'true' ]; then
#     exit 0
# fi
# Run tests
cd kubernetes/hdfs
helm test hdfs