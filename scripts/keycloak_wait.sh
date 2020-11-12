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

ENV_FILE="${__dir}/../.keycloak.env"

if [ $# -ge 1 ]; then
    ENV_FILE="${__dir}/../${1}"
else
    echo "WARN: ENV_FILE name not provided, using default ${ENV_FILE}"
    if [ ! -f "${ENV_FILE}" ]; then
        ENV_FILE="${__dir}/../.keycloak.dev.env"
        echo "WARN: Production env file not found, using dev. ${ENV_FILE}"
    fi
fi

if [ -f "${ENV_FILE}" ]; then
    # shellcheck disable=SC2046
    export $(< "${ENV_FILE}" sed 's/#.*//g')
else
    echo "ERROR: ${ENV_FILE} file not found."
    exit 1
fi

if [ -z "${KEYCLOAK_SERVER_ADDR+x}" ]; then
    echo "ERROR: KEYCLOAK_SERVER_PORT variable not provided!"
    exit 1
fi

echo -ne "Waiting Keycloak server to be ready"

until curl --output /dev/null --silent --head --fail "${KEYCLOAK_SERVER_ADDR}"
do
    printf '.'
    sleep 5
done