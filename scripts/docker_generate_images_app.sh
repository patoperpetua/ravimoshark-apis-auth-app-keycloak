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

if ! type "docker" &> /dev/null; then
    echo "Docker is not installed. Install it and then re launch"
    exit 1
fi

if ! type "awk" &> /dev/null; then
    echo "awk is not installed. Install it and then re launch"
    exit 1
fi

if ! type "curl" &> /dev/null; then
    echo "curl is not installed. Install it and then re launch"
    exit 1
fi

function usage(){
    echo -e "-h | --help: display help."
    echo -e "-p | --push: push images after building."
    echo -e "-x | --proxy: use proxy."
    echo -e "-b | --base-name: base name of images."
    echo -e "-c | --commit-sha: sha of commit to attach to image."
    echo -e "-t | --tag: tag of images."
}

DOCKER_BUILD_COMMIT_SHA="none"
DOCKER_BUILD_IMAGES_FOLDER="docker/keycloak"

if [ -z "${DOCKER_BUILD_BASE_NAME+x}" ]; then
    DOCKER_BUILD_BASE_NAME="registry.gitlab.com/ravimosharksas/apis/auth/app"
fi

if [ -z "${DOCKER_BUILD_TAG+x}" ]; then
    DOCKER_BUILD_TAG="latest"
fi

DOCKER_BUILD_FLAG_PROXY=0
DOCKER_BUILD_ENV_PROXY=""
DOCKER_BUILD_PUSH=0
DOCKER_BUILD_TAGS_FILES="tags"

while [ "${1+x}" != "" ]; do
    PARAM=$(echo "$1" | awk -F= '{print $1}')
    VALUE=$(echo "$1" | awk -F= '{print $2}')
    case $PARAM in
        -h | --help)
            usage
            exit
            ;;
        -p | --push)
            DOCKER_BUILD_PUSH=1
            ;;
        -x | --proxy)
            DOCKER_BUILD_FLAG_PROXY=1
            ;;
        -b | --base-name)
            DOCKER_BUILD_BASE_NAME=$VALUE
            ;;
        -c | --commit-sha)
            DOCKER_BUILD_COMMIT_SHA=$VALUE
            ;;
        -t | --tag)
            DOCKER_BUILD_TAG=$VALUE
            ;;
        *)
            echo "ERROR: unknown parameter \"$PARAM\""
            usage
            exit 1
            ;;
    esac
    shift
done

if [ "${DOCKER_BUILD_COMMIT_SHA}" == "none" ]; then
    if type "git" &> /dev/null; then
        if [ -d .git ]; then
            if git log >/dev/null; then
                DOCKER_BUILD_COMMIT_SHA=$(git rev-parse HEAD | cut -c 1-8)
            fi
        fi
    fi
fi

DATE="$(date -u +'%Y-%m-%dT%H:%M:%SZ')"

if [ "${DOCKER_BUILD_FLAG_PROXY}" == "1" ]; then
    echo "Running with proxy environment."
    DOCKER_BUILD_ENV_PROXY=".docker/.proxy"
fi

DOCKER_BUILD_FILE="${DOCKER_BUILD_IMAGES_FOLDER}/Dockerfile"
DOCKER_BUILD_IMAGE_NAME="app-"

input="${DOCKER_BUILD_IMAGES_FOLDER}/${DOCKER_BUILD_TAGS_FILES}"
while IFS= read -r BASE_IMAGE_TAG
do
    DOCKER_CONFIG="${DOCKER_BUILD_ENV_PROXY}" docker build --rm -f "${DOCKER_BUILD_FILE}" -t \
        "${DOCKER_BUILD_BASE_NAME}/${DOCKER_BUILD_IMAGE_NAME}-${BASE_IMAGE_TAG}:${DOCKER_BUILD_TAG}" \
        --label "version=${DOCKER_BUILD_TAG}" \
        --label "vcs-ref=${DOCKER_BUILD_COMMIT_SHA}" \
        --label "build-date=${DATE}" \
        --build-arg BASE_IMAGE_TAG="${BASE_IMAGE_TAG}" .
    if [ "${DOCKER_BUILD_PUSH}" == "1" ]; then
        docker push "${DOCKER_BUILD_BASE_NAME}/${DOCKER_BUILD_IMAGE_NAME}-${BASE_IMAGE_TAG}:${DOCKER_BUILD_TAG}"
    fi
done < "$input"
