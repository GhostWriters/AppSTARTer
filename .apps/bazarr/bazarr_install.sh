#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

bazarr_install() {
    if [[ ! -d ${APP_PATH} ]]; then
        info "Installing ${APPNAME}"
        git clone https://github.com/morpheus65535/bazarr.git "${APP_PATH}" > /dev/null 2>&1 || fatal "Failed to clone ${APPNAME} from git."
    else
        info "${APPNAME} already installed"
    fi
}
