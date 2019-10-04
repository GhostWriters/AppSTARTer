#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

env_create() {
    if [[ -f ${SCRIPTPATH}/.data/.env ]]; then
        info "${SCRIPTPATH}/.data/.env found."
    else
        warn "${SCRIPTPATH}/.data/.env not found. Copying example template."
        cp "${SCRIPTPATH}/.data/.env.example" "${SCRIPTPATH}/.data/.env" || fatal "${SCRIPTPATH}/.data/.env could not be copied."
        run_script 'set_permissions' "${SCRIPTPATH}/.data/.env"
    fi
    run_script 'env_sanitize'
}

test_env_create() {
    run_script 'env_create'
    cat "${SCRIPTPATH}/.data/.env"
}
