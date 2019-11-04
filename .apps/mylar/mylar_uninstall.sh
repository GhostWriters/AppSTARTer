#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

mylar_uninstall() {
    local SERVICE_NAME="${APPNAME,,}"

    local MYLAR_SCRIPT_DEFAULT="/etc/default/${SERVICE_NAME}"
    if [[ -f ${MYLAR_SCRIPT_DEFAULT} ]]; then
        info "Removing ${MYLAR_SCRIPT_DEFAULT}"
        rm -r "${MYLAR_SCRIPT_DEFAULT}"
    fi

    local MYLAR_SCRIPT_INITD="/etc/init.d/${SERVICE_NAME}"
    if [[ -f ${MYLAR_SCRIPT_INITD} ]]; then
        info "Removing ${MYLAR_SCRIPT_INITD}"
        rm -r "${MYLAR_SCRIPT_INITD}"
    fi
}
