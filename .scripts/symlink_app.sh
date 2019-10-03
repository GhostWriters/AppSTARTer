#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

symlink_app() {
    run_script 'set_permissions' "${SCRIPTNAME}"

    # /usr/bin/${APPLICATION_COMMAND}
    if [[ -L "/usr/bin/${APPLICATION_COMMAND}" ]] && [[ ${SCRIPTNAME} != "$(readlink -f "/usr/bin/${APPLICATION_COMMAND}")" ]]; then
        info "Attempting to remove /usr/bin/${APPLICATION_COMMAND} symlink."
        rm "/usr/bin/${APPLICATION_COMMAND}" || fatal "Failed to remove /usr/bin/${APPLICATION_COMMAND}"
    fi
    if [[ ! -L "/usr/bin/${APPLICATION_COMMAND}" ]]; then
        info "Creating /usr/bin/${APPLICATION_COMMAND} symbolic link for ${APPLICATION_NAME}."
        ln -s -T "${SCRIPTNAME}" "/usr/bin/${APPLICATION_COMMAND}" || fatal "Failed to create /usr/bin/${APPLICATION_COMMAND} symlink."
    fi

    # /usr/local/bin/${APPLICATION_COMMAND}
    if [[ -L "/usr/local/bin/${APPLICATION_COMMAND}" ]] && [[ ${SCRIPTNAME} != "$(readlink -f "/usr/local/bin/${APPLICATION_COMMAND}")" ]]; then
        info "Attempting to remove /usr/local/bin/${APPLICATION_COMMAND} symlink."
        rm "/usr/local/bin/${APPLICATION_COMMAND}" || fatal "Failed to remove /usr/local/bin/${APPLICATION_COMMAND}"
    fi
    if [[ ! -L "/usr/local/bin/${APPLICATION_COMMAND}" ]]; then
        info "Creating /usr/local/bin/${APPLICATION_COMMAND} symbolic link for ${APPLICATION_NAME}."
        ln -s -T "${SCRIPTNAME}" "/usr/local/bin/${APPLICATION_COMMAND}" || fatal "Failed to create /usr/local/bin/${APPLICATION_COMMAND} symlink."
    fi
}

test_symlink_app() {
    run_script 'symlink_app'
}
