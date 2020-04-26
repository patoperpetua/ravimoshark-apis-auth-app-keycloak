#!/usr/bin/env bash

# Web Page of BASH best practices https://kvz.io/blog/2013/11/21/bash-best-practices/
#Exit when a command fails.
set -o errexit
#Exit when script tries to use undeclared variables.
set -o nounset
#The exit status of the last command that threw a non-zero exit code is returned.
set -o pipefail

#Trace what gets executed. Useful for debugging.
#set -o xtrace

# Set magic variables for current file & dir
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[0]}")"
__base="$(basename "${__file}" .sh)"
__root="$(cd "$(dirname "${__dir}")" && pwd)"

echo "Script name: ${__base}"
echo "Executing at ${__root}"

eval "${__dir}/create_folders.sh"

KEY_CLOAK_PORT=9090
ENV_VARIABLES=

if [ -z "${DOCKER_KEYCLOAK_VERSION+x}" ]; then
    DOCKER_KEYCLOAK_VERSION=8.0.0
    echo "WARM: DOCKER_KEYCLOAK_VERSION variable not provided, using default ${DOCKER_KEYCLOAK_VERSION}"
fi

if [ "$#" -ge 1 ]; then
    KEY_CLOAK_PORT="${1}"
    echo "Provided keycloak app port: ${KEY_CLOAK_PORT}"
    ENV_VARIABLES="KEY_CLOAK_PORT=${KEY_CLOAK_PORT} FOLDER_IMPORTATIONS=volumes DOCKER_KEYCLOAK_VERSION=${DOCKER_KEYCLOAK_VERSION}"
fi


eval "${ENV_VARIABLES}" docker-compose -f docker/docker-compose.yaml up -d

echo -ne "Waiting Keycloak server to be ready"

until curl --output /dev/null --silent --head --fail http://localhost:"${KEY_CLOAK_PORT}"
do
    printf '.'
    sleep 5
done

eval "${__dir}/server_setup.sh"

echo "Access keycloak server under address http://localhost:${KEY_CLOAK_PORT}"
