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

MANDATORY_VARIABLES=("AZURE_DEFAULT_RESOURCE_GROUP" "AZURE_DEFAULT_LOCATION" "AZURE_DEFAULT_SUBSCRIPTION")

ENV_FILE="env/.test.azure.env"
if [ $# -ge 1 ]; then
    ENV_FILE="${1}"
else
    echo "WARN: ENV_FILE name not provided, using default ${ENV_FILE}"
fi

eval "${__dir}/check_env.sh" "${ENV_FILE}" "${MANDATORY_VARIABLES[@]}"

if [ -f "${ENV_FILE}" ]
then
    # shellcheck disable=SC2046
    export $(< "${ENV_FILE}" sed 's/#.*//g' | xargs)
    # export $(grep -v '^#' .env | xargs)
else
    echo "WARN ENV variable not found."
fi

dbs=($(az group list | jq -r .[].name))
create=true
for i in "${dbs[@]}"
do
    if [ "${i}" == "${AZURE_DEFAULT_RESOURCE_GROUP}" ]; then
        echo "Resource group already created"
        create=false
    fi
done

if [ "${create}" == "true" ]; then
    # Create a resource group
    echo "Creating resource group ${AZURE_DEFAULT_RESOURCE_GROUP}"
    az group create \
        --name "${AZURE_DEFAULT_RESOURCE_GROUP}" \
        --location "${AZURE_DEFAULT_LOCATION}" \
        --subscription "${AZURE_DEFAULT_SUBSCRIPTION}" \
        --tags "creator[=patricio]" subscription[="${AZURE_DEFAULT_SUBSCRIPTION}"]
fi
