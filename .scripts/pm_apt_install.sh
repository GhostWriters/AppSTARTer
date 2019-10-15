#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

pm_apt_install() {
    local APPNAME=${1:-}
    local APPDEPENDENCYOF=${2:-}
    local REDIRECT="> /dev/null 2>&1"
    if [[ ${CI:-} == true ]]; then
        REDIRECT="> /dev/null"
    fi
    if [[ ${APPNAME} != "" ]]; then
        local UPDATE_APT
        local SOURCE_REPO
        SOURCE_REPO=$(run_script 'yml_get' "${APPNAME}" "services.${FILENAME}.labels[com.appstarter.appinstall].apt.${DETECTED_DISTRO}.${DETECTED_CODENAME}.repo" || true)
        if [[ ${SOURCE_REPO} == "" ]]; then
            SOURCE_REPO=$(run_script 'yml_get' "${APPNAME}" "services.${FILENAME}.labels[com.appstarter.appinstall].apt.${DETECTED_DISTRO}.repo" || true)
        fi
        if [[ ${SOURCE_REPO} == "" ]]; then
            SOURCE_REPO=$(run_script 'yml_get' "${APPNAME}" "services.${FILENAME}.labels[com.appstarter.appinstall].apt.general.repo" || true)
        fi
        if [[ ${SOURCE_REPO} != "" ]]; then
            if [[ ${SOURCE_REPO} == deb* ]]; then
                local SOURCE_FILE="/etc/apt/sources.list.d/${APPNAME,,}.list"
                local SOURCE_EXISTS
                SOURCE_EXISTS=$(grep -c "${SOURCE_REPO}" "${SOURCE_FILE}" || echo "0")
                local SOURCE_LINE_COUNT
                SOURCE_LINE_COUNT=$(wc -l "${SOURCE_FILE}" | awk '{print $1}' || echo "0")
                if [[ ${SOURCE_EXISTS} = 1 || ${SOURCE_LINE_COUNT} -gt 1 ]]; then
                    info "Adding/updating sources for ${APPNAME}"
                    if [[ -f ${SOURCE_FILE} ]]; then
                        rm "${SOURCE_FILE}"
                    fi
                    echo "${SOURCE_REPO}" | tee "${SOURCE_FILE}" > /dev/null
                    UPDATE_APT="true"
                fi
            elif [[ ${SOURCE_REPO} == ppa:* ]]; then
                info "Adding/updating sources for ${APPNAME}"
                add-apt-repository -y "${SOURCE_REPO}" > /dev/null
                UPDATE_APT="true"
            else
                error "Source Repo is an invalid format. Must start be 'deb' or 'ppa:'!"
                error "${SOURCE_REPO}"
                return 1
            fi
        fi

        local SOURCE_KEY
        SOURCE_KEY=$(run_script 'yml_get' "${APPNAME}" "services.${FILENAME}.labels[com.appstarter.appinstall].apt.${DETECTED_DISTRO}.${DETECTED_CODENAME}.key" || true)
        if [[ ${SOURCE_KEY} == "" ]]; then
            SOURCE_KEY=$(run_script 'yml_get' "${APPNAME}" "services.${FILENAME}.labels[com.appstarter.appinstall].apt.${DETECTED_DISTRO}.key" || true)
        fi
        if [[ ${SOURCE_KEY} == "" ]]; then
            SOURCE_KEY=$(run_script 'yml_get' "${APPNAME}" "services.${FILENAME}.labels[com.appstarter.appinstall].apt.general.key" || true)
        fi
        if [[ ${SOURCE_KEY} != "" ]]; then
            if [[ ${SOURCE_KEY} == http* ]]; then
                info "Adding/updating source key for ${APPNAME}"
                wget -qO - "${SOURCE_KEY}" | apt-key add -  > /dev/null 2>&1 || error "Unable to add key for ${APPNAME}: ${SOURCE_KEY}"
                UPDATE_APT="true"
            else
                if ! gpg --list-keys "${SOURCE_KEY}" > /dev/null 2>&1; then
                    info "Adding source key for ${APPNAME}"
                    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys "${SOURCE_KEY}" > /dev/null 2>&1
                    UPDATE_APT="true"
                fi
            fi
        fi

        if [[ ${UPDATE_APT:-} == "true" ]]; then
            run_script 'package_manager_run' repos
        fi

        PACKAGE_VERSION_INSTALLED=$(sudo apt-cache policy "${APP_PACKAGE}" | grep "Installed:" | awk '{gsub("Installed:", ""); gsub(" ", ""); print}')
        PACKAGE_VERSION_CANDIDATE=$(sudo apt-cache policy "${APP_PACKAGE}" | grep "Candidate:" | awk '{gsub("Candidate:", ""); gsub(" ", ""); print}')
        if [[ ${PACKAGE_VERSION_INSTALLED} == "" || ${PACKAGE_VERSION_INSTALLED} != "${PACKAGE_VERSION_CANDIDATE}" ]]; then
            if [[ ${APPDEPENDENCYOF} == "" ]]; then
                notice "Installing or updating ${APPNAME} via apt"
            else
                info "Installing or updating ${APPNAME} via apt (${APPDEPENDENCYOF} dependency)"
            fi

            local APP_PACKAGE
            APP_PACKAGE=$(run_script 'yml_get' "${APPNAME}" "services.${FILENAME}.labels[com.appstarter.appinstall].apt.${DETECTED_DISTRO}.name" || true)
            if [[ ${APP_PACKAGE} == "" ]]; then
                APP_PACKAGE=$(run_script 'yml_get' "${APPNAME}" "services.${FILENAME}.labels[com.appstarter.appinstall].apt.general.name" || true)
            fi

            apt-get -y install "${APP_PACKAGE}" > /dev/null 2>&1 || error "Failed to install/update ${APPNAME} from apt."

            run_script 'package_manager_run' clean
        else
            info "Package already install and up-to-date!"
        fi
    else
        info "Installing dependencies."
        eval apt-get -y install apt-transport-https ca-certificates curl git gnupg2 grep sed software-properties-common whiptail "${REDIRECT}" || fatal "Failed to install dependencies from apt."
    fi
}

test_pm_apt_install() {
    run_script 'pm_apt_repos'
    run_script 'pm_apt_install'
}
