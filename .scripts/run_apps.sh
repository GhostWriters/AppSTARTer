#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

run_apps() {
    while IFS= read -r line; do
        local APPNAME=${line%%_ENABLED=true}
        APPNAME=${APPNAME,,}
        APPNICENAME=$(run_script 'yml_get' "${APPNAME}" "services.${APPNAME,,}.labels[com.appstarter.appinfo.nicename]" || echo "${APPNAME^}")
        run_script "app_install" "${APPNICENAME}"
    done < <(grep '_ENABLED=true$' < "${SCRIPTPATH}/.data/.env")
}

test_run_apps() {
    warn "CI does not test run_apps."
}
