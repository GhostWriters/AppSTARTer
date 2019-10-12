#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

bazarr_post_install() {
    info "Installing ${APPNAME} requirements"
    sudo -H -u "${APP_USER}" bash -c "cd '${APP_PATH}'; pip install -U -r requirements.txt" > /dev/null 2>&1 || error "Unable to install requirements for ${APPNAME}"
}
