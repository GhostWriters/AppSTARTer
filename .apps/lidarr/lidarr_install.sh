#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

lidarr_install() {
    if [[ ! -d ${APP_PATH} ]]; then
        info "Installing or updating ${APPNAME}"
        curl -s -L -O "$(curl -s https://api.github.com/repos/Lidarr/Lidarr/releases | grep linux.tar.gz | grep browser_download_url | head -1 | cut -d '"' -f 4)" > /dev/null 2>&1 || fatal "Failed retrieve ${APPNAME}."
        mkdir -p "${APP_PATH}"
        tar -xvzf Lidarr.master.*.linux.tar.gz -C "${APP_PATH%${APPNAME}*}" > /dev/null 2>&1 || fatal "Failed to unpack ${APPNAME}"
        rm Lidarr.master.*.linux.tar.gz || error "Failed to remove  ${APPNAME} zip file."
    else
        info "${APPNAME} already installed"
    fi
}
