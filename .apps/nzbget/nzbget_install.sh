#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

nzbget_install()
{
    local APPNAME="${1:-}"
    local APP_USER="${APPNAME,,}"
    local APP_UID=$(id -u "${APP_USER}")
    local APP_GID=$(id -g "${APP_USER}")

    if [[ ! -d "${APP_PATH}" ]]; then
        info "Getting ${APPNAME}"
        wget -q https://nzbget.net/download/nzbget-latest-bin-linux.run || fatal "Failed to retrieve ${APPNAME} installer."
        info "Running ${APPNAME} install"
        bash nzbget-latest-bin-linux.run --destdir "${APP_PATH}" > /dev/null 2>&1 || fatal "Failed install ${APPNAME}."
        rm nzbget-latest-bin-linux.run || error "Failed to remove  ${APPNAME} installer."
    else
        info "${APPNAME} already installed"
    fi

    if [[ -f "${APP_PATH}/nzbget.conf" ]]; then
        info "Setting DaemonUsername in ${APPNAME} config"
        sed -i "s#DaemonUsername=.*#DaemonUsername=${APP_USER}#g" "${APP_PATH}/nzbget.conf"
    fi
}
