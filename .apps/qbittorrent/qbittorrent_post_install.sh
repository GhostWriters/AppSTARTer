#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

qbittorrent_post_install() {
    if [[ ! -d ${APP_CONFDIR_PATH} ]]; then
        mkdir -p "${APP_CONFDIR_PATH}"
    fi

    local CONFIG_FILE="${APP_CONFDIR_PATH}/qBittorrent.conf"
    if [[ ! -f ${CONFIG_FILE} ]]; then
        touch "${CONFIG_FILE}"
        echo "[LegalNotice]" >> "${CONFIG_FILE}"
        echo "Accepted=true" >> "${CONFIG_FILE}"
    fi

    if [[ ! -d "/home/qbittorrent/.config/" ]]; then
        mkdir -p "/home/qbittorrent/.config/"
        ln -s "${APP_CONFDIR_PATH}" "/home/qbittorrent/.config/qBittorrent"
    fi

    chmod -R 770 "/home/qbittorrent/.config/"
    chown -R "${APP_USER}":"${APP_USER}" "/home/qbittorrent/.config/"
    chmod -R 770 "${APP_CONFDIR_PATH}"
    chown -R "${APP_USER}":"${APP_USER}" "${APP_CONFDIR_PATH}"
}
