#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

add_user_to_group() {
    local USER="${1:-}"
    local GROUP="${2:-}"

    if groups "${USER}" | grep &> /dev/null "\b${GROUP}\b"; then
        info "User '${USER}' is already part of the '${GROUP}' group!"
    else
        if [[ ! $(getent group "${GROUP}") ]]; then
            info "Group '${GROUP}' does not exist. Adding."
            groupadd "${GROUP}"
        fi
        info "Adding '${USER}' user to '${GROUP}' group"
        usermod -a -G "${GROUP}" "${USER}" > /dev/null 2>&1 || warn "Unable to add '${USER}' user to '${GROUP}' group"
    fi
}

test_add_user_to_group() {
    warn "CI does not test add_user_to_group."
}
