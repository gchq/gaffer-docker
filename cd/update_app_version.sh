#!/bin/bash

set -e

# Gets project root directory by calling two nested "dirname" commands on the this file 
getRootDirectory() {
    echo "$( cd $(dirname $(dirname $0)) > /dev/null 2>&1 && pwd )"
}

# Get version in app_version
getAppVersion() {
    root_dir="$(getRootDirectory)"
    echo "$(cat ${root_dir}/app_version)"
}

# Get Command name ("update_app_version.sh")
getCommand() {
    echo "$(basename $0)"
}

# Increments the bugfix version by 1
createNewVersion() {
    old_version="$1"
    major_and_minor="$(echo ${old_version} | sed 's|^\(.*\.\).*|\1|')"
    bugfix="$(echo ${old_version} | sed 's|.*\.||')"
    let "bugfix++"
    echo "${major_and_minor}""${bugfix}"
}

# Performs a Find and replace on the Helm charts and the app_version file
findAndReplace() {
    find "$(getRootDirectory)" \( -iname Chart.y*ml -o -name app_version \) -exec sed -i'' -e "s:$1:$2:g" {} +
}

if [ $# -gt 1 ]; then
    echo "
    Usage: $(getCommand) <new_version>
    "
    exit 1
fi

new_version=$1

app_version="$(getAppVersion)"

if [ -z "${new_version}" ]; then
    new_version="$(createNewVersion ${app_version})"
fi

findAndReplace "${app_version}" "${new_version}"