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

source "${__dir}/create_folders.sh"

KEY_CLOAK_PORT=
ENV_VARIABLES=
if [ "$#" -ge 1 ]; then
    KEY_CLOAK_PORT="${1}"
    echo "Provided keycloak app port: ${KEY_CLOAK_PORT}"
    ENV_VARIABLES="KEY_CLOAK_PORT=${KEY_CLOAK_PORT}"
fi

eval "${ENV_VARIABLES}" docker-compose up -d

