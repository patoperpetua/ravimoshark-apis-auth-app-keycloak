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

if [ -f .keycloak.env ]
then
    # shellcheck disable=SC2046
    export $(< .env sed 's/#.*//g' | xargs)
    # export $(grep -v '^#' .env.swagger | xargs)
fi

alias kcadm.sh=/opt/jboss/keycloak/bin/kcadm.sh

if [ -z "${KEYCLOAK_SERVER_PORT+x}" ]; then
    echo: "ERROR: KEYCLOAK_SERVER_PORT variable not provided!"
    exit 1
fi

if [ -z "${KEYCLOAK_SERVER_USER+x}" ]; then
    echo: "ERROR: KEYCLOAK_SERVER_USER variable not provided!"
    exit 1
fi

if [ -z "${KEYCLOAK_SERVER_PASSWORD+x}" ]; then
    echo: "ERROR: KEYCLOAK_SERVER_PASSWORD variable not provided!"
    exit 1
fi

kcadm.sh config credentials \
    --server http://localhost:${KEYCLOAK_SERVER_PORT}/auth \
    --realm master --user ${KEYCLOAK_SERVER_USER} --password ${KEYCLOAK_SERVER_PASSWORD}

# shellcheck disable=SC1090
source "${__dir}/keycloak_create_realm.sh"

# shellcheck disable=SC1090
source "${__dir}/keycloak_create_groups.sh"

# shellcheck disable=SC1090
source "${__dir}/keycloak_create_users_mock.sh"

# shellcheck disable=SC1090
source "${__dir}/keycloak_create_clients.sh"
