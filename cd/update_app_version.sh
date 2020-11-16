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

# Gets project root directory by calling two nested "dirname" commands on the this file
getRootDirectory() {
    echo "$( cd $(dirname $(dirname $0)) > /dev/null 2>&1 && pwd )"
}

# Get Command name ("update_app_version.sh")
getCommand() {
    echo "$(basename $0)"
}

# Performs a Find and replace on the Helm charts and the app_version file
findAndReplace() {
    # Replace version marked with # managed version in the Chart.yaml files
    managed_version_tag='# managed version'
    find "$(getRootDirectory)" -iname Chart.y*ml -exec sed -i'' -e "s:[0-9]*\.[0-9]*\.[0-9]* ${managed_version_tag}:$1 ${managed_version_tag}:g" {} +
}

if [ $# -ne 1 ]; then
    echo "
    Usage: $(getCommand) <new_version>
    "
    exit 1
fi

new_version=$1

findAndReplace "${new_version}"
