#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

env_get() {
    local GET_VAR=${1:-}
    grep --color=never -Po "^${GET_VAR}=\K.*" "${SCRIPTPATH}/.data/.env" || true
}

test_env_get() {
    run_script 'env_get' APPCONFDIR
}
