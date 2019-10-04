#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

pm_yum_install() {
    local APPNAME=${1:-}
    local APP_PACKAGE=${2:-}
    if [[ ${APPNAME} != "" && ${APP_PACKAGE} != "" ]]; then
        yum -y install "${APP_PACKAGE}" > /dev/null 2>&1 || error "Failed to install/update ${APPNAME} from yum."
    else
        info "Installing dependencies."
        yum -y install curl git grep rsync sed whiptail > /dev/null 2>&1 || fatal "Failed to install dependencies from yum."
    fi
}

test_pm_yum_install() {
    # run_script 'pm_yum_install'
    warn "CI does not test pm_yum_install."
}
