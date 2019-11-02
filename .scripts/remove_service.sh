#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

remove_service() {
    local APPNAME="${1:-}"
    local SERVICE_NAME="${APPNAME,,}"
    if [[ -n "$(command -v systemctl)" ]]; then
        local SERVICE_FILE="/lib/systemd/system/${SERVICE_NAME}.service"

        if [[ -f ${SERVICE_FILE} ]]; then
            info "Disabling ${APPNAME} service"
            systemctl disable "${SERVICE_NAME}"
            info "Stopping ${APPNAME} service"
            systemctl stop "${SERVICE_NAME}"

            rm -r "${SERVICE_FILE}"
            systemctl daemon-reload
        fi
    else
        error "Unable to remove ${APPNAME} service. systemctl does not exist."
    fi
}

test_remove_service() {
    warn "CI does not test create_service."
}
