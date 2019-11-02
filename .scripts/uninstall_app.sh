#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

uninstall_app() {
    local APPNAME="${1:-}"
    local APP_USER="${APPNAME,,}"
    local APPDEPENDENCYOF="${2:-}"
    local FILENAME=${APPNAME,,}
    local RUN_PRE_INSTALL=1
    local RUN_POST_INSTALL=0
    local APPDEPENDENCY=0
    local APP_UID
    local APP_GID
    local APP_PATH
    local APPCONFDIR
    APPCONFDIR=$(run_script 'env_get' APPCONFDIR)
    local APP_CONFDIR_PATH="${APPCONFDIR}/${APPNAME,,}"
    local APP_CONFIG_PATH
    local YMLAPPINSTALL="services.${FILENAME}.labels[com.appstarter.appinstall]"

    if [[ ${APPDEPENDENCYOF} == "" ]]; then
        notice "Uninstalling ${APPNAME}"
    else
        info "Uninstalling dependency of ${APPDEPENDENCYOF} - ${APPNAME}"
        APPDEPENDENCY=1
    fi

    if [[ ${APPNAME} != "" ]]; then
        # Dependencies
        # while IFS= read -r line; do
        #     run_script 'uninstall_app' "${line}" "${APPNAME}"
        # done < <(run_script 'yml_get' "${APPNAME}" "${YMLAPPINSTALL}.dependencies.general" | awk '{ gsub("- ", ""); print}' || true)
        # while IFS= read -r line; do
        #     run_script 'uninstall_app' "${line}" "${APPNAME}"
        # done < <(run_script 'yml_get' "${APPNAME}" "${YMLAPPINSTALL}.dependencies.${DETECTED_DISTRO}" | awk '{ gsub("- ", ""); print}' || true)

        # Install information
        APP_PATH=$(run_script 'yml_get' "${APPNAME}" "${YMLAPPINSTALL}.config.${DETECTED_DISTRO}.${DETECTED_CODENAME}.app_path" || true)
        debug "APP_PATH for ${APPNAME}: '${APP_PATH}' from '${YMLAPPINSTALL}.config.${DETECTED_DISTRO}.${DETECTED_CODENAME}.app_path'"
        if [[ ${APP_PATH} == "" ]]; then
            APP_PATH=$(run_script 'yml_get' "${APPNAME}" "${YMLAPPINSTALL}.config.${DETECTED_DISTRO}.app_path" || true)
            debug "APP_PATH for ${APPNAME}: '${APP_PATH}' from '${YMLAPPINSTALL}.config.${DETECTED_DISTRO}.app_path'"
        fi
        if [[ ${APP_PATH} == "" ]]; then
            APP_PATH=$(run_script 'yml_get' "${APPNAME}" "${YMLAPPINSTALL}.config.general.app_path" || true)
            debug "APP_PATH for ${APPNAME}: '${APP_PATH}' from '${YMLAPPINSTALL}.config.general.app_path'"
        fi

        if [[ ${APP_PATH} == "true" ]]; then
            APP_PATH="/opt/${APPNAME}"
        elif [[ ${APP_PATH} != "false" ]]; then
            APP_PATH="${APP_PATH%%+(/)}"
        fi

        local INSTALL_METHOD
        INSTALL_METHOD=$(run_script 'yml_get' "${APPNAME}" "${YMLAPPINSTALL}.config.${DETECTED_DISTRO}.${DETECTED_CODENAME}.method" || true)
        debug "INSTALL_METHOD for ${APPNAME}: '${APP_PATH}' from '${YMLAPPINSTALL}.config.${DETECTED_DISTRO}.${DETECTED_CODENAME}.method'"
        if [[ ${INSTALL_METHOD} == "" ]]; then
            INSTALL_METHOD=$(run_script 'yml_get' "${APPNAME}" "${YMLAPPINSTALL}.config.${DETECTED_DISTRO}.method" || true)
            debug "INSTALL_METHOD for ${APPNAME}: '${APP_PATH}' from '${YMLAPPINSTALL}.config.${DETECTED_DISTRO}.method'"
        fi
        if [[ ${INSTALL_METHOD} == "" ]]; then
            INSTALL_METHOD=$(run_script 'yml_get' "${APPNAME}" "${YMLAPPINSTALL}.config.general.method" || true)
            debug "INSTALL_METHOD for ${APPNAME}: '${APP_PATH}' from '${YMLAPPINSTALL}.config.general.method'"
        fi

        if [[ ${INSTALL_METHOD} == "package" || ${INSTALL_METHOD} == "package-manager" || ${INSTALL_METHOD} == "package manager" || ${INSTALL_METHOD} == "pm" ]]; then
            if run_script 'package_manager_run' "uninstall" "${APPNAME}" "${APPDEPENDENCYOF}"; then
                RUN_POST_UNINSTALL=1
            fi
        elif [[ ${INSTALL_METHOD} == "built-in" || ${INSTALL_METHOD} == "custom" ]]; then
            if [[ -f "${SCRIPTPATH}/.apps/${FILENAME}/${FILENAME}_uninstall.sh" ]]; then
                # shellcheck source=/dev/null
                source "${SCRIPTPATH}/.apps/${FILENAME}/${FILENAME}_uninstall.sh"
                if "${FILENAME}_uninstall" "${APPNAME}"; then
                    RUN_POST_UNINSTALL=1
                fi
            elif [[ -f "${SCRIPTPATH}/.scripts/uninstall_${FILENAME}.sh" ]]; then
                if run_script "uninstall_${FILENAME}" "${APPNAME}"; then
                    RUN_POST_UNINSTALL=1
                fi
            fi
            cd "${SCRIPTPATH}" || fatal "Failed to change to ${SCRIPTPATH} directory."

            if [[ -d ${APP_PATH} ]]; then
                info "Removing '${APP_PATH}'"
                rm -r "${APP_PATH}" > /dev/null 2>&1 || error "Failed to remove '${APP_PATH}'."
            else
                notice "${APPNAME} not installed"
            fi
        else
            error "No install method for ${APPNAME} (needs this to know how to uninstall)"
        fi

        run_script 'remove_service' "${APPNAME}"

        cd "${SCRIPTPATH}" || fatal "Failed to change to ${SCRIPTPATH} directory."
    else
        error "No app name provided."
    fi
}

test_uninstall_app() {
    warn "CI does not test uninstall_app."
}
