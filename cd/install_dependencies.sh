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

set -e

project_root="$( cd $(dirname $(dirname $0)) > /dev/null 2>&1 && pwd )"
cd ${project_root}/kubernetes

getDependencies(){
    cat Chart.yaml | sed -e '1,/dependencies/d' | grep name | sed 's/^.\{8\}//' 
}

checkIfModuleHasChart(){
    if [[  -f Chart.yaml  ]]; then
        if [[ $(grep -L "dependencies" Chart.yaml) ]]; then   
            echo "false"     
        fi
    else
        echo "false"
    fi    
}

#identifies and retains only those dependent modules that have dependencies themselves 
fetchAndVerifyDependencies(){
    dependencies=$(getDependencies)
    for dependency in $dependencies ; do
        if [[ $kubernetesComponents = *$dependency* ]]; then
            cd ../$dependency 
            if [[ $(checkIfModuleHasChart) == "false" ]]; then
                dependencies=${dependencies//$dependency/} 
            fi    
        else
            dependencies=${dependencies//$dependency/}    
        fi 
    done
    echo "$dependencies" 
}

#checks for overlaping dependencies between elements in the array, merging them where they exist
orderAndCompileDependencies(){
    IFS='/' read -a arr <<< "$1" 
    list=()
    for i in "${arr[@]}"; do
        firstWord=`echo "$i" | awk '{print $1}'` 
        for (( idx=${#arr[@]}-1 ; idx>=0 ; idx-- )) ; do
            lastWord=`echo "${arr[idx]}" | awk '{print $NF}'`
            if [[ "$i" == "${arr[idx]}" ]]; then 
                continue
            else    
                if [[ "$firstWord" == "$lastWord" ]]; then
                    list=("${arr[idx]}" "${list[@]}")
                else
                    continue
                fi
            fi        
        done 
    done                   
    for chart in "${list[@]}"; do
        charts_to_resolve+="$chart "
    done
    echo "$charts_to_resolve"
}

buildStringContainingDependencies(){
    dependencies+=$1 
    dependencies+=" "
    dependencies+=$(fetchAndVerifyDependencies)
    dependencies+="/"
    echo "$dependencies"
}

resolveDependencies(){
    kubernetesComponents=$(ls)
    for chart in $kubernetesComponents; do
        cd $chart
        if [[ $(checkIfModuleHasChart) == "false" ]]; then
            cd ..
            continue
        fi 
        dependencyList+="$(buildStringContainingDependencies $chart)"   
        cd ..
    done 
    charts_to_resolve="$(orderAndCompileDependencies "$dependencyList")"
    echo "$charts_to_resolve" | xargs -n1 | sort -u | xargs
}


# Resolve dependencies of these charts in order
for chart in $(resolveDependencies); do	
    helm dependency update ${chart}
done
