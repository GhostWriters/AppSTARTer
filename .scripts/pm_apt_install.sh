#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

pm_apt_install() {
    local APPNAME=${1:-}
    local REDIRECT="> /dev/null 2>&1"
    if [[ ${CI:-} == true ]]; then
        REDIRECT="> /dev/null"
    fi
    if [[ ${APPNAME} != "" ]]; then
        notice "Installing or updating ${APPNAME} via apt"
        local APP_PACKAGE
        APP_PACKAGE=$(run_script 'yml_get' "${APPNAME}" "services.${FILENAME}.labels[com.appstarter.appinstall].apt_name" || true)
        local SOURCE_FILE="/etc/apt/sources.list.d/${APPNAME,,}.list"
        local SOURCE_REPO
        SOURCE_REPO=$(run_script 'yml_get' "${APPNAME}" "services.${FILENAME}.labels[com.appstarter.appinstall].apt_repo" || true)
        if [[ ${SOURCE_FILE} != "" && ${SOURCE_REPO} != "" ]]; then
            info "Adding/updating sources for ${APPNAME}"
            if [[ -f ${SOURCE_FILE} ]]; then
                rm "${SOURCE_FILE}"
            fi
            echo "${SOURCE_REPO}" | tee "${SOURCE_FILE}" > /dev/null
        fi

        local SOURCE_KEY
        SOURCE_KEY=$(run_script 'yml_get' "${APPNAME}" "services.${FILENAME}.labels[com.appstarter.appinstall].apt_key" || true)
        if [[ ${SOURCE_KEY} != "" ]]; then
            info "Adding/updating source key for ${APPNAME}"
            gpg --list-keys "${SOURCE_KEY}" > /dev/null 2>&1 || apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "${SOURCE_KEY}" > /dev/null 2>&1
        fi

        run_script 'package_manager_run' repos
        apt-get -y install "${APP_PACKAGE}" > /dev/null 2>&1 || error "Failed to install/update ${APPNAME} from apt."
        run_script 'package_manager_run' clean
    else
        info "Installing dependencies."
        eval apt-get -y install apt-transport-https curl git gnupg2 grep sed whiptail "${REDIRECT}" || fatal "Failed to install dependencies from apt."
    fi
}

test_pm_apt_install() {
    run_script 'pm_apt_repos'
    run_script 'pm_apt_install'
}
