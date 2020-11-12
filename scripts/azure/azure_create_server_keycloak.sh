#!/usr/bin/env bash

# https://docs.microsoft.com/en-us/cli/azure/container?view=azure-cli-latest#az-container-create

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

MANDATORY_VARIABLES=("AZURE_DEFAULT_RESOURCE_GROUP" "AZURE_DEFAULT_LOCATION" "AZURE_DEFAULT_SUBSCRIPTION" "AZURE_DB_ADMIN_USER" "AZURE_DB_ADMIN_PASS" "AZURE_DB_SERVER_NAME" "AZURE_DB_DB_NAME" "AZURE_CONTAINER_NAME" "AZURE_CONTAINER_IMAGE_NAME" "AZURE_CONTAINER_DNS_NAME")

ENV_FILE="env/.test.azure.env"
if [ $# -ge 1 ]; then
    ENV_FILE="${1}"
else
    echo "WARN: ENV_FILE name not provided, using default ${ENV_FILE}"
fi

eval "${__root}/check_env.sh" "${ENV_FILE}" "${MANDATORY_VARIABLES[@]}"

if [ -f "${ENV_FILE}" ]
then
    # shellcheck disable=SC2046
    export $(< "${ENV_FILE}" sed 's/#.*//g' | xargs)
    # export $(grep -v '^#' .env | xargs)
else
    echo "WARN ENV variable not found."
fi

CONTAINER_ENV_VARIABLES=("KEYCLOAK_USER=${AZURE_CONTAINER_ADMIN_USER}" "KEYCLOAK_PASSWORD=${AZURE_CONTAINER_ADMIN_PASSWORD}" "DB_VENDOR=mssql" "DB_USER=${AZURE_DB_ADMIN_USER}" "DB_PASSWORD=${AZURE_DB_ADMIN_PASS}" "DB_ADDR=${AZURE_DB_SERVER_NAME}.database.windows.net" "DB_DATABASE=${AZURE_DB_DB_NAME}" "KEYCLOAK_HTTP_PORT=80" "KEYCLOAK_HTTPS_PORT=443" "KEYCLOAK_ALWAYS_HTTPS=true" "PROXY_ADDRESS_FORWARDING=true" "WEBSITES_PORT=8080")

az webapp create \
    --name "${AZURE_CONTAINER_NAME}" \
    --plan "${AZURE_CONTAINER_PLAN}" \
    --deployment-container-image-name "${AZURE_CONTAINER_IMAGE_NAME}" \
    --tags "creator[=patricio]" subscription[="${AZURE_DEFAULT_SUBSCRIPTION}"] \
    --resource-group "${AZURE_DEFAULT_RESOURCE_GROUP}" \
    --subscription "${AZURE_DEFAULT_SUBSCRIPTION}"

az webapp config appsettings set \
    --name "${AZURE_CONTAINER_NAME}" \
    --settings "${CONTAINER_ENV_VARIABLES[@]}" \
    --resource-group "${AZURE_DEFAULT_RESOURCE_GROUP}" \
    --subscription "${AZURE_DEFAULT_SUBSCRIPTION}"
