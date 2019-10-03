#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

create_service() {
    local APPNAME="${1:-}"
    local SERVICE_NAME="${APPNAME,,}"
    if [[ -n "$(command -v systemctl)" ]]; then
        local SERVICE_FILE="${SCRIPTPATH}/.apps/${SERVICE_NAME}/${SERVICE_NAME}.service"
        if [[ -f "${SERVICE_FILE}" ]]; then
            info "Copying ${APPNAME} .service file to system"
            cp "${SERVICE_FILE}" "/lib/systemd/system/${SERVICE_NAME}.service"
            sed -i "s#{APP_PATH}#${APP_PATH}#g" "/lib/systemd/system/${SERVICE_NAME}.service"

            if [[ -f "/lib/systemd/system/${SERVICE_NAME}.service" ]]; then
                systemctl daemon-reload
                info "Enabling ${APPNAME} service"
                systemctl enable "${SERVICE_NAME}"
                info "Starting ${APPNAME} service"
                systemctl start "${SERVICE_NAME}"
            fi
        else
            error "Unable to create ${APPNAME} service. .service file does not exist for ${APPNAME}"
        fi
    else
        error "Unable to create ${APPNAME} service. systemctl does not exist."
    fi
}