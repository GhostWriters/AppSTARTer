#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

install_app()
{
    local APPNAME="${1:-}"
    local APP_USER="${APPNAME,,}"
    local APPDEPENDENCYOF="${2:-}"
    local FILENAME=${APPNAME,,}
    local RUN_PRE_INSTALL=1
    local RUN_POST_INSTALL=0
    local APPDEPENDENCY=0

    if [[ ${APPDEPENDENCYOF} == "" ]]; then
        notice "Installing ${APPNAME}"
    else
        info "Installing dependency of ${APPDEPENDENCYOF} - ${APPNAME}"
        APPDEPENDENCY=1
    fi
    # Dependencies
    while IFS= read -r line; do
        run_script 'install_app' "${line}" "${APPNAME}"
    done < <(run_script 'yml_get' "${APPNAME}" "services.${FILENAME}.labels[com.appstarter.appinstall].dependencies" | awk '{ gsub("- ", ""); print}' || true)

    if [[ ${APPNAME} != "" ]]; then
        local APP_PATH
        APP_PATH=$(run_script 'yml_get' "${APPNAME}" "services.${FILENAME}.labels[com.appstarter.appinstall].app_path" || true)
        debug "APP_PATH for ${APPNAME}: '${APP_PATH}' from 'services.${FILENAME}.labels[com.appstarter.appinstall].app_path'"
        if [[ ${APP_PATH} == "true" ]]; then
            APP_PATH="/opt/${APPNAME}"
        else
             APP_PATH="${APP_PATH%%+(/)}"
        fi

        local INSTALL_METHOD
        INSTALL_METHOD=$(run_script 'yml_get' "${APPNAME}" "services.${FILENAME}.labels[com.appstarter.appinstall].method" || true)
        info "INSTALL_METHOD=${INSTALL_METHOD}"

        if [[ ${RUN_PRE_INSTALL} == 1 ]]; then
            if [[ ${APPDEPENDENCY} == 0 ]]; then
                info "Running general pre-install"
                run_script 'create_app_user' "${APP_USER}"
            fi
            if [[ -f "${SCRIPTPATH}/.apps/${FILENAME}/${FILENAME}_pre_install.sh" ]]; then
                info "Running additional ${APPNAME} pre-install script before ${APPNAME} install"
                source "${SCRIPTPATH}/.apps/${FILENAME}/${FILENAME}_pre_install.sh"
                ${FILENAME}_pre_install "${APPNAME}"
            fi
        fi
        cd "${SCRIPTPATH}" || fatal "Failed to change to ${SCRIPTPATH} directory."

        if [[ ${INSTALL_METHOD} == "package" || ${INSTALL_METHOD} == "package-manager"|| ${INSTALL_METHOD} == "package manager" || ${INSTALL_METHOD} == "pm" ]]; then
            if run_script 'package_manager_run' "install" "${APPNAME}"; then
                RUN_POST_INSTALL=1
            fi
        elif [[ ${INSTALL_METHOD} == "built-in" || ${INSTALL_METHOD} == "custom" || ${INSTALL_METHOD} == "" ]]; then
            if [[ -f "${SCRIPTPATH}/.apps/${FILENAME}/${FILENAME}_install.sh" ]]; then
                source "${SCRIPTPATH}/.apps/${FILENAME}/${FILENAME}_install.sh"
                if "${FILENAME}_install" "${APPNAME}"; then
                    RUN_POST_INSTALL=1
                fi
            elif [[ -f "${SCRIPTPATH}/.scripts/install_${FILENAME}.sh" ]]; then
                if run_script "install_${FILENAME}" "${APPNAME}"; then
                    RUN_POST_INSTALL=1
                fi
            else
                error "No install file for ${APPNAME}"
            fi
        else
            error "No install method for ${APPNAME}"
        fi
        cd "${SCRIPTPATH}" || fatal "Failed to change to ${SCRIPTPATH} directory."

        if [[ ${RUN_POST_INSTALL} == 1 ]]; then
            if [[ ${APPDEPENDENCY} == 0 ]]; then
                info "Running general post-install after successful ${APPNAME} install"
                if [[ ${APP_PATH} != "" ]]; then
                    local APP_UID=$(id -u "${APP_USER}")
                    local APP_GID=$(id -g "${APP_USER}")
                    run_script 'set_permissions' "${APP_PATH}" "${APP_UID}" "${APP_GID}"
                    #chmod -R 770 "${APP_PATH}"
                    #chown -R "${APP_USER}":"${APP_USER}" "${APP_PATH}"
                else
                    warn "Cannot update permissions. No path provided for ${APPNAME}."
                fi
            fi

            if [[ -f "${SCRIPTPATH}/.apps/${FILENAME}/${FILENAME}_post_install.sh" ]]; then
                info "Running additional ${APPNAME} post install script after successful ${APPNAME} install"
                source "${SCRIPTPATH}/.apps/${FILENAME}/${FILENAME}_post_install.sh"
                ${FILENAME}_post_install "${APPNAME}"
            fi

            if [[ ${APPDEPENDENCY} == 0 ]]; then
                run_script 'create_service' "${APPNAME}"
            fi
        else
            error "Post-install cannot run because ${APPNAME} install had an error"
        fi
        cd "${SCRIPTPATH}" || fatal "Failed to change to ${SCRIPTPATH} directory."
    else
        error "No app name provided."
    fi
}

test_install_app() {
    warn "CI does not test install_app."
}
