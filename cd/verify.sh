#!/bin/bash

set -e

if [ ${TRAVIS_PULL_REQUEST} == 'false' ]; then
    exit 0
fi

# Run tests
helm test gaffer
