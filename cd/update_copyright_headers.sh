#!/bin/bash

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
