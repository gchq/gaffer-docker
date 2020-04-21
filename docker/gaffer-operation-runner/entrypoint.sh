#!/bin/bash

function join { local IFS="$1"; shift; echo "$*"; }

graph_id=$1

if [ -z $graph_id ]; then
    echo "Missing argument Graph ID"
    exit 1
fi
echo "Using Graph Id: ${graph_id}"
# Find all the Jars and produce comma seperated list
jars=()
while IFS=  read -r -d $'\0'; do
    jars+=("$REPLY")
done < <(find /gaffer/jars -name "*.jar" -print0)

jar_files=$(join , ${jars[@]})

accumulo -add "${jar_files}" uk.gov.gchq.gaffer.docker.App /gaffer/operation/operation.json /gaffer/schema /gaffer/store/store.properties "${graph_id}"
