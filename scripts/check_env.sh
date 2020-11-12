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

ENV_FILE="env/.test.azure.env"
if [ $# -ge 2 ]; then
    ENV_FILE="${1}"
    echo "ENV_FILE: ${ENV_FILE}"
    shift
else
    echo "WARN: ENV_FILE name not provided, using default ${ENV_FILE}"
fi

if [ -f "${ENV_FILE}" ]
then
    # shellcheck disable=SC2046
    export $(< "${ENV_FILE}" sed 's/#.*//g' | xargs)
    # export $(grep -v '^#' .env | xargs)
else
    echo "WARN ENV variable not found."
fi
echo -ne "Checking mandatory env variables "

while [ "${1+x}" != "" ]; do
    VARIABLE="${1}"
    if [ -z "${!VARIABLE+x}" ]; then
        echo "FAIL"
        echo "ERROR: ${VARIABLE} not provided. Finishing execution."
        exit 1
    fi
    shift
done
echo "DONE"