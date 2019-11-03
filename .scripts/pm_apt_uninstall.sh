#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

pm_apt_uninstall() {
    local APPNAME=${1:-}
    local APPDEPENDENCYOF=${2:-}
    if [[ ${APPNAME} != "" ]]; then
        local UPDATE_APT
        local SOURCE_REPO
        local YMLAPPINSTALL="services.${FILENAME}.labels[com.appstarter.appinstall]"

        PACKAGE_VERSION_INSTALLED=$(sudo apt-cache policy "${APP_PACKAGE}" | grep -Po "Installed: \K.*" || true)
        if [[ ${PACKAGE_VERSION_INSTALLED} != "" ]]; then
            if [[ ${APPDEPENDENCYOF} == "" ]]; then
                info "Uninstalling ${APPNAME} via apt"
            else
                info "Uninstalling ${APPNAME} via apt (${APPDEPENDENCYOF} dependency)"
            fi

            local APP_PACKAGE
            APP_PACKAGE=$(run_script 'yml_get' "${APPNAME}" "${YMLAPPINSTALL}.apt.${DETECTED_DISTRO}.${DETECTED_CODENAME}.name" || true)
            if [[ ${APP_PACKAGE} == "" ]]; then
                APP_PACKAGE=$(run_script 'yml_get' "${APPNAME}" "${YMLAPPINSTALL}.apt.${DETECTED_DISTRO}..name" || true)
            fi
            if [[ ${APP_PACKAGE} == "" ]]; then
                APP_PACKAGE=$(run_script 'yml_get' "${APPNAME}" "${YMLAPPINSTALL}.apt.general.name" || true)
            fi

            apt-get -y purge "${APP_PACKAGE}" > /dev/null 2>&1 || error "Failed to uninstall ${APPNAME} from apt. It was probably already uninstalled."

            run_script 'package_manager_run' clean

            SOURCE_REPO=$(run_script 'yml_get' "${APPNAME}" "${YMLAPPINSTALL}.apt.${DETECTED_DISTRO}.${DETECTED_CODENAME}.repo" || true)
            if [[ ${SOURCE_REPO} == "" ]]; then
                SOURCE_REPO=$(run_script 'yml_get' "${APPNAME}" "${YMLAPPINSTALL}.apt.${DETECTED_DISTRO}.repo" || true)
            fi
            if [[ ${SOURCE_REPO} == "" ]]; then
                SOURCE_REPO=$(run_script 'yml_get' "${APPNAME}" "${YMLAPPINSTALL}.apt.general.repo" || true)
            fi
            if [[ ${SOURCE_REPO} != "" ]]; then
                if [[ ${SOURCE_REPO} == deb* ]]; then
                    local SOURCE_FILE="/etc/apt/sources.list.d/${APPNAME,,}.list"
                    if [[ -f ${SOURCE_FILE} ]]; then
                        info "Removing sources for ${APPNAME}"
                        rm "${SOURCE_FILE}"
                    fi
                elif [[ ${SOURCE_REPO} == ppa:* ]]; then
                    info "Removing sources for ${APPNAME}"
                    add-apt-repository -y --remove "${SOURCE_REPO}" > /dev/null
                else
                    error "Source Repo is an invalid format. Must start be 'deb' or 'ppa:'!"
                    error "${SOURCE_REPO}"
                    return 1
                fi
            fi

            run_script 'package_manager_run' clean
            run_script 'package_manager_run' repos
        else
            warn "Package is not installed!"
        fi
    else
        error "No app name provided. Cannot uninstall."
    fi
}

test_pm_apt_uninstall() {
    warn "CI does not test pm_apt_install."
}
