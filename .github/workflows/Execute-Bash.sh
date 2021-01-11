#!/bin/bash
# markdown bash execute
if [ -f "$1" ]; then
    cat $1 | # print the file
    sed '/Uninstall/Q' | # ignore text after match
    sed -n '/```bash/,/```/p' | # get the bash code blocks
    sed 's/```bash//g' | #  remove the ```bash
    sed 's/```//g' | # remove the trailing ```
    sed '/^$/d' | # remove empty lines
    /usr/bin/env sh ; # execute the command
else
    echo "${1} is not valid" ;
fi
