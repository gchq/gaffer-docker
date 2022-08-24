#!/bin/bash

# Copyright 2020 Crown Copyright
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

graph_id=$1

if [ -z $graph_id ]; then
    echo "Missing argument Graph ID"
    exit 1
fi
echo "Using Graph Id: ${graph_id}"

export CLASSPATH=/gaffer/jars/*:/opt/accumulo/lib/ext/*
accumulo uk.gov.gchq.gaffer.docker.App /gaffer/operation/operation.json /gaffer/schema /gaffer/store/store.properties "${graph_id}"
