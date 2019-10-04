#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

env_backup() {
    run_script 'env_create'
    local APPCONFDIR
    APPCONFDIR=$(run_script 'env_get' APPCONFDIR)
    BACKUPDIR="${APPCONFDIR}/.${APPLICATION_NAME_CLEAN}.backups"
    info "Taking ownership of ${APPCONFDIR} (non-recursive)."
    chown "${DETECTED_PUID}":"${DETECTED_PGID}" "${APPCONFDIR}" > /dev/null 2>&1 || true
    local BACKUPTIME
    BACKUPTIME=$(date +"%Y%m%d%H%M%S")
    info "Copying .env file to ${BACKUPDIR}/.env.${BACKUPTIME}"
    mkdir -p "${BACKUPDIR}" || fatal "${BACKUPDIR} folder could not be created."
    cp "${SCRIPTPATH}/.data/.env" "${BACKUPDIR}/.env.${BACKUPTIME}" || fatal "${BACKUPDIR}/.env.${BACKUPTIME} could not be copied."
    run_script 'set_permissions' "${BACKUPDIR}"
    info "Removing old .env backups."
    find "${BACKUPDIR}" -type f -name ".env.*" -mtime +3 -delete > /dev/null 2>&1 || warn "Old .env backups not removed."
}

test_env_backup() {
    run_script 'env_backup'
}
