#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

package_manager_run() {
    local ACTION="${1:-}"
    local APPNAME="${2:-}"
    local APP_PACKAGE="${3:-}"
    local SOURCE_FILE="${4:-}"
    local SOURCE_REPO="${5:-}"
    local SOURCE_KEY="${6:-}"
    if [[ -n "$(command -v apt-get)" ]]; then
        run_script "pm_apt_${ACTION}" "${APPNAME}" "${APP_PACKAGE}" "${SOURCE_FILE}" "${SOURCE_REPO}" "${SOURCE_KEY}"
    elif [[ -n "$(command -v dnf)" ]]; then
        run_script "pm_dnf_${ACTION}" "${APPNAME}" "${APP_PACKAGE}" "${SOURCE_FILE}" "${SOURCE_REPO}" "${SOURCE_KEY}"
    elif [[ -n "$(command -v yum)" ]]; then
        run_script "pm_yum_${ACTION}" "${APPNAME}" "${APP_PACKAGE}" "${SOURCE_FILE}" "${SOURCE_REPO}" "${SOURCE_KEY}"
    else
        fatal "Package manager not detected!"
    fi
}

test_package_manager_run() {
    run_script 'package_manager_run' clean
}
