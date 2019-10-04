#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

radarr_install() {
    if [[ ! -d "/opt/${APPNAME}" ]]; then
        info "Installing ${APPNAME}"
        curl -s -L -O "$(curl -s https://api.github.com/repos/Radarr/Radarr/releases | grep linux.tar.gz | grep browser_download_url | head -1 | cut -d '"' -f 4)"
        mkdir -p "${APP_PATH}"
        tar -xvzf Radarr.develop.*.linux.tar.gz -C "${APP_PATH%${APPNAME}*}" > /dev/null 2>&1 || fatal "Failed to unpack ${APPNAME}"
        rm Radarr.develop.*.linux.tar.gz || error "Failed to remove  ${APPNAME} zip file."
    else
        info "${APPNAME} already installed"
    fi
}
