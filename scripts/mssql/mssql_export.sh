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

KEYCLOAK_ENV_FILE="${__root}/../.keycloak.env"
if [ $# -ge 1 ]; then
    KEYCLOAK_ENV_FILE="${__root}/../${1}"
else
    echo "WARN: ENV_FILE name not provided, using default ${KEYCLOAK_ENV_FILE}"
fi

if [ ! -f "${KEYCLOAK_ENV_FILE}" ]; then
    echo "ERROR: ENV file does not exists. ${KEYCLOAK_ENV_FILE}"
    exit 1
fi

docker run --rm -it --name "${DOCKER_NAME}_MSSQL_BACKUP" \
    mcr.microsoft.com/mssql-tools \
    /opt/mssql-tools/bin/sqlcmd -S 172.17.0.1 -U sa -P "${PASSWORD_DB}" \
    -Q "BACKUP DATABASE [Keycloak] TO DISK = N'/opt/exportations/keycloak.bak'"