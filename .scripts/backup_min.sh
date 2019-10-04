#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

backup_min() {
    info "Backing up /.data/.env files."
    local BACKUP_CMD_PRE_RUN
    BACKUP_CMD_PRE_RUN=$(run_script 'env_get' BACKUP_CMD_PRE_RUN)
    eval "${BACKUP_CMD_PRE_RUN}" || error "Failed to execute BACKUP_CMD_PRE_RUN."
    run_script 'env_update'
    run_script 'backup_create' ".${APPLICATION_NAME_CLEAN}.backups"
    local BACKUP_CMD_POST_RUN
    BACKUP_CMD_POST_RUN=$(run_script 'env_get' BACKUP_CMD_POST_RUN)
    eval "${BACKUP_CMD_POST_RUN}" || error "Failed to execute BACKUP_CMD_POST_RUN."
    info "All backups complete."
}

test_backup_min() {
    run_script 'backup_min'
}
