#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

bazarr_uninstall() {
    if [[ -f ${APP_PATH}/requirements.txt ]]; then
        info "Removing dependenicies via pip"
        sudo -H -u "${APP_USER}" bash -c "cd '${APP_PATH}'; pip uninstall -y -r requirements.txt" > /dev/null 2>&1 || error "Unable to uninstall requirements for ${APPNAME}"
    fi
}
