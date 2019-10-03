#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

env_update() {
    run_script 'env_backup'
    # run_script 'override_backup'
    info "Replacing current /.data/.env file with latest template."
    local CURRENTENV
    CURRENTENV=$(mktemp) || fatal "Failed to create temporary /.data/.env update file."
    sort "${SCRIPTPATH}/.data/.env" > "${CURRENTENV}" || fatal "${SCRIPTPATH}/.data/.env could not be copied."
    rm -f "${SCRIPTPATH}/.data/.env" || warn "${SCRIPTPATH}/.data/.env could not be removed."
    cp "${SCRIPTPATH}/.data/.env.example" "${SCRIPTPATH}/.data/.env" || fatal "${SCRIPTPATH}/.data/.env.example could not be copied."
    run_script 'set_permissions' "${SCRIPTPATH}/.data/.env"
    info "Merging previous values into new /.data/.env file."
    while IFS= read -r line; do
        local SET_VAR=${line%%=*}
        local SET_VAL=${line#*=}
        if grep -q "^${SET_VAR}=" "${SCRIPTPATH}/.data/.env"; then
            run_script 'env_set' "${SET_VAR}" "${SET_VAL}"
        else
            echo "${line}" >> "${SCRIPTPATH}/.data/.env" || error "${line} could not be written to ${SCRIPTPATH}/.data/.env"
        fi
    done < <(grep '=' < "${CURRENTENV}")
    rm -f "${CURRENTENV}" || warn "Failed to remove temporary /.data/.env update file."
    run_script 'env_sanitize'
    info "Environment file update complete."
}

test_env_update() {
    run_script 'env_update'
}
