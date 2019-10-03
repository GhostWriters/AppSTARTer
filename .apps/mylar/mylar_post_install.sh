#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

mylar_post_install()
{
    local APPNAME="${1:-}"
    local APP_USER="${APPNAME,,}"
    local APP_UID=$(id -u "${APP_USER}")
    local APP_GID=$(id -g "${APP_USER}")
    local SERVICE_NAME="${APPNAME,,}"

    local MYLAR_SCRIPT_DEFAULT="/etc/default/${SERVICE_NAME}"
    info "Copying mylar.default to '${MYLAR_SCRIPT_DEFAULT}'"
    cp "${SCRIPTPATH}/.apps/${SERVICE_NAME}/${SERVICE_NAME}.default" "${MYLAR_SCRIPT_DEFAULT}"
    run_script 'set_permissions' "${MYLAR_SCRIPT_DEFAULT}" "${APP_UID}" "${APP_GID}"

    local MYLAR_SCRIPT_INITD="/etc/init.d/${SERVICE_NAME}"
    info "Copying mylar.initd to '${MYLAR_SCRIPT_INITD}'"
    cp "${SCRIPTPATH}/.apps/${SERVICE_NAME}/${SERVICE_NAME}.initd" "${MYLAR_SCRIPT_INITD}"
    chmod u+x "${MYLAR_SCRIPT_INITD}"
}
