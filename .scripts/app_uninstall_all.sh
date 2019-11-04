#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

app_uninstall_all() {
    if grep -q '_ENABLED=false$' "${SCRIPTPATH}/.data/.env"; then
        local PREPROMPT=${PROMPT:-}
        if [[ ${CI:-} != true ]] && [[ ${PROMPT:-} != "GUI" ]]; then
            PROMPT="CLI"
        fi
        if [[ ${CI:-} != true ]] && run_script 'question_prompt' "${PROMPT:-}" N "Would you like to uninstall disabled apps?"; then
            info "Unistalling disabled apps."
            while IFS= read -r line; do
                local APPNAME=${line%%_ENABLED=*}
                APPNAME=${APPNAME,,}
                APPNICENAME=$(run_script 'yml_get' "${APPNAME}" "services.${APPNAME,,}.labels[com.appstarter.appinfo.nicename]" || echo "${APPNAME^}")
                run_script 'app_uninstall' "${APPNICENAME}"
            done < <(grep '_ENABLED=false$' < "${SCRIPTPATH}/.data/.env")
        fi
        PROMPT=${PREPROMPT:-}
    else
        notice "${SCRIPTPATH}/.data/.env does not contain any${APPS_UNINSTALL} apps to uninstall."
    fi
}

test_app_uninstall() {
    warn "CI does not test app_uninstall."
}
