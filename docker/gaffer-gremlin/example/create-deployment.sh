#!/bin/sh
# Copyright 2024 Crown Copyright
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

CURRENT_DIR="$(dirname "$(readlink -f "${0}")")"
TINKERPOP_MODERN_JSON="${CURRENT_DIR}/conf/gaffer/data/tinkerpop-modern.json"
GAFFER_REST_URL="http://localhost:8080"

# Make sure we have an evironment file for the image versions
if [ ! -f "${1}" ]; then
    echo "Error - Environment file not set"
    echo "Example: ${0} <envfile>.env"
    exit 1
fi

# Remove any existing containers
docker compose --env-file "${1}" -f "${CURRENT_DIR}/compose.yaml" down

# Start new deployment
echo "-----------------------------------"
echo "Starting new deployment..."
docker compose --env-file "${1}" -f "${CURRENT_DIR}/compose.yaml" up --detach

# Check can connect to instance
echo "-----------------------------------"
echo "Attempting to connect to Gaffer instance..."
if ! docker run --rm --network=host curlimages/curl:latest \
            curl --retry 20 \
                 --retry-delay 5 \
                 --retry-all-errors "${GAFFER_REST_URL}"/rest/graph/status
then
    echo "Failed to connect to Gaffer instance"
    exit 1
fi

# Load dataset
echo "-----------------------------------"
echo "Loading data into Gaffer instance..."
if ! docker run --rm --network=host curlimages/curl:latest \
            curl -H "Content-Type: application/json" \
                 --data "$(cat "${TINKERPOP_MODERN_JSON}")" "${GAFFER_REST_URL}"/rest/graph/operations/execute
then
    echo "Failed to load tinkerpop modern JSON: ${TINKERPOP_MODERN_JSON}"
    exit 1
fi

echo "-----------------------------------"
echo "Deployment started!"
