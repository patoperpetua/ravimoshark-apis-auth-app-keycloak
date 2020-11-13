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

MANDATORY_VARIABLES=("AZURE_DEFAULT_RESOURCE_GROUP" "AZURE_DEFAULT_LOCATION" "AZURE_DEFAULT_SUBSCRIPTION" "AZURE_DB_ADMIN_USER" "AZURE_DB_ADMIN_PASS" "AZURE_DB_SERVER_NAME" "AZURE_DB_DB_NAME")

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

if [ $# -ge 2 ]; then
    AZURE_DB_ADMIN_PASS="${2}"
fi

# The ip address range that you want to allow to access your DB.
# Leaving at 0.0.0.0 will prevent outside-of-azure connections to your DB
startip=0.0.0.0
endip=0.0.0.0

echo "Setting default subscription to ${AZURE_DEFAULT_SUBSCRIPTION}"
# Set the subscription context for the Azure account
az account set -s "${AZURE_DEFAULT_SUBSCRIPTION}"

createServer=true
mapfile -t servers < <(az sql server list | jq -r .[].name)
#servers=($(az sql server list | jq -r .[].name))
for i in "${servers[@]}"
do
    if [ "${i}" == "${AZURE_DB_SERVER_NAME}" ]; then
        echo "Server already created"
        createServer=false
    fi
done

if [ "${createServer}" == "true" ]; then
    # Create a logical server in the resource group
    echo "Creating sql server ${AZURE_DB_SERVER_NAME}"
    az sql server create \
        --name "${AZURE_DB_SERVER_NAME}" \
        --resource-group "${AZURE_DEFAULT_RESOURCE_GROUP}" \
        --location "${AZURE_DEFAULT_LOCATION}"  \
        --admin-user "${AZURE_DB_ADMIN_USER}" \
        --admin-password "${AZURE_DB_ADMIN_PASS}"

    #Configure a firewall rule for the server
    echo "Configuring firewall..."
    az sql server firewall-rule create \
        --resource-group "${AZURE_DEFAULT_RESOURCE_GROUP}" \
        --server "${AZURE_DB_SERVER_NAME}" \
        -n AllowYourIp \
        --start-ip-address "${startip}" \
        --end-ip-address "${endip}"
fi

mapfile -t dbs < <(az sql db list --server "${AZURE_DB_SERVER_NAME}" --resource-group "${AZURE_DEFAULT_RESOURCE_GROUP}" | jq -r .[].name)
# dbs=($(az sql db list --server "${AZURE_DB_SERVER_NAME}" --resource-group "${AZURE_DEFAULT_RESOURCE_GROUP}" | jq -r .[].name))
createServer=true
for i in "${dbs[@]}"
do
    if [ "${i}" == "${AZURE_DB_DB_NAME}" ]; then
        echo "Database already created"
        createServer=false
    fi
done

if [ "${createServer}" == "true" ]; then
    # # Create a gen5 1vCore database in the server
    echo "Creating a gen5 2 vCore database..."
    az sql db create \
        --resource-group "${AZURE_DEFAULT_RESOURCE_GROUP}" \
        --server "${AZURE_DB_SERVER_NAME}" \
        --name "${AZURE_DB_DB_NAME}" \
        --sample-name AdventureWorksLT \
        --edition GeneralPurpose \
        --family Gen5 \
        --capacity 2 \
        --tags "creator[=patricio]" subscription[="${AZURE_DEFAULT_SUBSCRIPTION}"] group[="${AZURE_DEFAULT_RESOURCE_GROUP}"]
fi