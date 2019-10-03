#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

pm_dnf_install() {
    local APPNAME=${1:-}
    local APP_PACKAGE=${2:-}
    if [[ ${APPNAME} != "" && ${APP_PACKAGE} != "" ]]; then
        dnf -y install "${APP_PACKAGE}" > /dev/null 2>&1 || error "Failed to install/update ${APPNAME} from apt."
    else
        info "Installing dependencies."
        dnf -y install curl git grep sed whiptail > /dev/null 2>&1 || fatal "Failed to install dependencies from dnf."
    fi
}

test_pm_dnf_install() {
    # run_script 'pm_dnf_install'
    warn "CI does not test pm_dnf_install."
}
