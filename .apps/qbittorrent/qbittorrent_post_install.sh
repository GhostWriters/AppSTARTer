#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

qbittorrent_post_install()
{
    local CONFIG_PATH="${DETECTED_HOMEDIR}/.config/${APPNAME}"
    local CONFIG_FILE="${CONFIG_PATH}/qBittorrent.conf"
    if [[ ! -d "${CONFIG_PATH}" ]]; then
        mkdir -p "${CONFIG_PATH}"
        touch "${CONFIG_FILE}"
        echo "[LegalNotice]" >> "${CONFIG_FILE}"
        echo "Accepted=true" >> "${CONFIG_FILE}"
    fi

    if [[ ! -d "/home/qbittorrent/.config/" ]]; then
        mkdir -p "/home/qbittorrent/.config/"
        ln -s "${CONFIG_PATH}" "/home/qbittorrent/.config/qBittorrent"
    fi

    chmod -R 770 "/home/qbittorrent/.config/"
    chown -R "${APP_USER}":"${APP_USER}" "/home/qbittorrent/.config/"
    chmod -R 770 "${CONFIG_PATH}"
    chown -R "${APP_USER}":"${APP_USER}" "${CONFIG_PATH}"
}
