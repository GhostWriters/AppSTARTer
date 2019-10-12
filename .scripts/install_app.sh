#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

install_app() {
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
        APP_PATH=$(run_script 'yml_get' "${APPNAME}" "services.${FILENAME}.labels[com.appstarter.appinstall].app_path" || true)
        debug "APP_PATH for ${APPNAME}: '${APP_PATH}' from 'services.${FILENAME}.labels[com.appstarter.appinstall].app_path'"
        if [[ ${APP_PATH} == "true" ]]; then
            APP_PATH="/opt/${APPNAME}"
        elif [[ ${APP_PATH} != "false" ]]; then
            APP_PATH="${APP_PATH%%+(/)}"
        fi

        local INSTALL_METHOD
        INSTALL_METHOD=$(run_script 'yml_get' "${APPNAME}" "services.${FILENAME}.labels[com.appstarter.appinstall].method" || true)
        info "INSTALL_METHOD=${INSTALL_METHOD}"

        if [[ ${RUN_PRE_INSTALL} == 1 ]]; then
            if [[ ${APPDEPENDENCY} == 0 ]]; then
                info "Running general pre-install"
                run_script 'create_app_user' "${APP_USER}"
                APP_UID=$(id -u "${APP_USER}")
                APP_GID=$(id -g "${APP_USER}")
            fi
            if [[ -f "${SCRIPTPATH}/.apps/${FILENAME}/${FILENAME}_pre_install.sh" ]]; then
                info "Running additional ${APPNAME} pre-install script before ${APPNAME} install"
                # shellcheck source=/dev/null
                source "${SCRIPTPATH}/.apps/${FILENAME}/${FILENAME}_pre_install.sh"
                "${FILENAME}_pre_install" "${APPNAME}"
            fi
        fi
        cd "${SCRIPTPATH}" || fatal "Failed to change to ${SCRIPTPATH} directory."

        if [[ ${INSTALL_METHOD} == "package" || ${INSTALL_METHOD} == "package-manager" || ${INSTALL_METHOD} == "package manager" || ${INSTALL_METHOD} == "pm" ]]; then
            if run_script 'package_manager_run' "install" "${APPNAME}"; then
                RUN_POST_INSTALL=1
            fi
        elif [[ ${INSTALL_METHOD} == "built-in" || ${INSTALL_METHOD} == "custom" || ${INSTALL_METHOD} == "" ]]; then
            if [[ -f "${SCRIPTPATH}/.apps/${FILENAME}/${FILENAME}_install.sh" ]]; then
                # shellcheck source=/dev/null
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
                # Give the app time to create files; probably doesn't need to be 30s
                info "Waiting 30 seconds for ${APPNAME} to initialize..."
                sleep 30s
                if [[ ${APP_PATH} != "" ]]; then
                    run_script 'set_permissions' "${APP_PATH}" "${APP_UID}" "${APP_GID}"
                elif [[ ${APP_PATH} != "false" ]]; then
                    warn "Cannot set permissions in general post-install. No path provided for ${APPNAME}."
                fi
                # Config path handling
                while IFS= read -r line; do
                    local APP_CONFIG_PATH=${line}
                    local CONFIG_PATH="${APP_CONFIG_PATH}"
                    local CONFIG_PATH_EXISTS="false"
                    local CONFIG_PATH_IS_LINK="false"
                    local NEW_CONFIG_PATH="${APP_CONFDIR_PATH}"
                    local NEW_CONFIG_PATH_EXISTS="false"
                    local CONFIG_PATHS_LINKED="false"

                    if [[ ${APP_CONFIG_PATH} != "" ]]; then
                        if [[ ${APP_PATH} != "" ]] && [[ ${APP_CONFIG_PATH} != /* ]]; then
                            CONFIG_PATH="${APP_PATH}/${APP_CONFIG_PATH}"
                        fi

                        if [[ -d ${CONFIG_PATH} ]]; then
                            info "${CONFIG_PATH} is a directory"
                            CONFIG_PATH_EXISTS="true"
                        elif [[ -f ${CONFIG_PATH} ]]; then
                            info "${CONFIG_PATH} is a file"
                            CONFIG_PATH_EXISTS="true"
                            NEW_CONFIG_PATH="${APP_CONFDIR_PATH}/${APP_CONFIG_PATH}"
                            info "Creating ${APPLICATION_NAME} for ${APPNAME}"
                            mkdir -p "${APP_CONFDIR_PATH}"
                        else
                            info "${CONFIG_PATH} is nothing"
                        fi

                        if [[ -L ${CONFIG_PATH} ]]; then
                            CONFIG_PATH_IS_LINK="true"
                        fi

                        if [[ -d ${NEW_CONFIG_PATH} || -f ${NEW_CONFIG_PATH} ]]; then
                            NEW_CONFIG_PATH_EXISTS="true"
                            if [[ ${CONFIG_PATH_IS_LINK} == "true" && ${NEW_CONFIG_PATH} == "$(readlink -f "${CONFIG_PATH}")" ]]; then
                                CONFIG_PATHS_LINKED="true"
                            elif [[ ${CONFIG_PATH_IS_LINK} == "true" ]]; then
                                info "Removing existing link: ${APP_CONFIG_PATH} => $(readlink -f "${APP_CONFIG_PATH}")"
                                rm ${APP_CONFIG_PATH}
                            fi
                        fi
                        info "APP_CONFIG_PATH=${APP_CONFIG_PATH}"
                        info "CONFIG_PATH=${CONFIG_PATH}"
                        info "CONFIG_PATH_EXISTS=${CONFIG_PATH_EXISTS}"
                        info "CONFIG_PATH_IS_LINK=${CONFIG_PATH_IS_LINK}"
                        info "NEW_CONFIG_PATH=${NEW_CONFIG_PATH}"
                        info "NEW_CONFIG_PATH_EXISTS=${NEW_CONFIG_PATH_EXISTS}"
                        info "CONFIG_PATHS_LINKED=${CONFIG_PATHS_LINKED}"

                        if [[ ${CONFIG_PATH_EXISTS} != "true" && ${NEW_CONFIG_PATH_EXISTS} == "true" ]]; then
                            # Config already moved; need to link
                            info "Linking ${APPNAME} config path to ${APPLICATION_NAME} config path: ${CONFIG_PATH} => ${NEW_CONFIG_PATH}"
                            ln -s "${NEW_CONFIG_PATH}" "${CONFIG_PATH}"
                        elif [[ ${CONFIG_PATH_EXISTS} == "true" && ${NEW_CONFIG_PATH_EXISTS} == "true" && ${CONFIG_PATHS_LINKED} == "true" ]]; then
                            # Both exist and linked!
                            info "${APPNAME} config path already linked to ${APPLICATION_NAME} config path!"
                        elif [[ ${CONFIG_PATH_EXISTS} == "true" && ${NEW_CONFIG_PATH_EXISTS} == "true" && ${CONFIG_PATHS_LINKED} == "false" ]]; then
                            # Both exist but not linked
                            info "Moving ${APPNAME} config path to ${CONFIG_PATH}.bak"
                            mv "${CONFIG_PATH}" "${CONFIG_PATH}.bak"
                            info "Linking ${APPNAME} config path to ${APPLICATION_NAME} config path: ${CONFIG_PATH} => ${NEW_CONFIG_PATH}"
                            ln -s "${NEW_CONFIG_PATH}" "${CONFIG_PATH}"
                        elif [[ ${CONFIG_PATH_EXISTS} == "true" && ${NEW_CONFIG_PATH_EXISTS} != "true" ]]; then
                            # Config path exists but not the new one
                            info "Moving ${APPNAME} config path to ${APPLICATION_NAME} config path: ${CONFIG_PATH} => ${NEW_CONFIG_PATH}"
                            mv "${CONFIG_PATH}" "${NEW_CONFIG_PATH}"
                            info "Linking ${APPNAME} config path to ${APPLICATION_NAME} config path: ${CONFIG_PATH} => ${NEW_CONFIG_PATH}"
                            ln -s "${NEW_CONFIG_PATH}" "${CONFIG_PATH}"
                        elif [[ ${CONFIG_PATH_EXISTS} != "true" && ${NEW_CONFIG_PATH_EXISTS} != "true" ]]; then
                            # Both don't exist
                            error "${APPNAME} config path is not a valid directory or file: ${CONFIG_PATH}"
                        else
                            error "Something wasn't handled properly"
                            info "APP_CONFIG_PATH=${APP_CONFIG_PATH}"
                            info "CONFIG_PATH=${CONFIG_PATH}"
                            info "CONFIG_PATH_EXISTS=${CONFIG_PATH_EXISTS}"
                            info "CONFIG_PATH_IS_LINK=${CONFIG_PATH_IS_LINK}"
                            info "NEW_CONFIG_PATH=${NEW_CONFIG_PATH}"
                            info "NEW_CONFIG_PATH_EXISTS=${NEW_CONFIG_PATH_EXISTS}"
                            info "CONFIG_PATHS_LINKED=${CONFIG_PATHS_LINKED}"
                        fi

                        run_script 'set_permissions' "${APP_CONFDIR_PATH}" "${APP_UID}" "${APP_GID}"
                    else
                        warn "Cannot move and link ${APPNAME} config. No config path provided."
                    fi
                done < <(run_script 'yml_get' "${APPNAME}" "services.${FILENAME}.labels[com.appstarter.appinstall].config_path" | awk '{ gsub("- ", ""); print}' || true)
            fi

            if [[ -f "${SCRIPTPATH}/.apps/${FILENAME}/${FILENAME}_post_install.sh" ]]; then
                info "Running additional ${APPNAME} post install script after successful ${APPNAME} install"
                # shellcheck source=/dev/null
                source "${SCRIPTPATH}/.apps/${FILENAME}/${FILENAME}_post_install.sh"
                "${FILENAME}_post_install" "${APPNAME}"
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
