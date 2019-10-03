#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

create_app_user() {
    local APP_USER="${1:-}"
    if [[ $(id -u "${APP_USER}" 2>/dev/null | wc -l) != 1 ]]; then
        info "Creating user and group for '${APP_USER}'"
        if [[ ! $(getent group "${APP_USER}") ]]; then
            useradd -s /usr/sbin/nologin -d /home/"${APP_USER}" -r -m -U "${APP_USER}"
        else
            useradd -s /usr/sbin/nologin -d /home/"${APP_USER}" -r -m "${APP_USER}" -g "${APP_USER}"
        fi
    fi

    run_script 'add_user_to_group' "${APP_USER}" "${APPLICATION_NAME_CLEAN}"
    run_script 'add_user_to_group' "${DETECTED_UNAME}" "${APP_USER}"
}