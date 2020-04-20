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

# Note that the copyright of this header is not automatically updated.

set -e

currentYear=$(date +%Y)
rootDirectory=$( cd $(dirname $(dirname $0)) > /dev/null 2>&1 && pwd )


for f in $(find "${rootDirectory}" -type f -name '*.txt' -o -name '*.xml' -o -name '*.java' -o -name '*.yml' -o -name '*.yaml' -o -name '*.sh' -o -name '*.tpl' -o -name '*.md' -o -name ".env" -o -name 'Dockerfile' -o -name '.*ignore' -o -name 'NOTICES');
do
    echo ${f}
    for startYear in `seq 2016 1 $((currentYear - 1))`;
    do
        sedCmd="s/Copyright ${startYear} Crown Copyright/Copyright ${startYear}-${currentYear} Crown Copyright/g"
        sed -i'' -e "$sedCmd" ${f}
        rm -f ${f}-e
        if [ $((startYear+1)) -lt ${currentYear} ]; then
            for endYear in `seq $((startYear + 1)) 1 $((currentYear - 1))`;
            do
                sedCmd="s/Copyright ${startYear}-${endYear} Crown Copyright/Copyright ${startYear}-${currentYear} Crown Copyright/g"
                sed -i'' -e "$sedCmd" ${f}
                rm -f ${f}-e
            done
        fi
    done
done
