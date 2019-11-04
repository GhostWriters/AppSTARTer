#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

appvars_purge_all() {
    if grep -q '_ENABLED=false$' "${SCRIPTPATH}/.data/.env"; then
        local PREPROMPT=${PROMPT:-}
        if [[ ${CI:-} != true ]] && [[ ${PROMPT:-} != "GUI" ]]; then
            PROMPT="CLI"
        fi
        if [[ ${CI:-} == true ]] || run_script 'question_prompt' "${PROMPT:-}" N "Would you like to purge variables for all disabled and uninstalled apps?"; then
            info "Purging disabled app variables."
            while IFS= read -r line; do
                local APPNAME=${line%%_ENABLED=false}
                if grep -q "${APPNAME^^}_INSTALLED=false$" "${SCRIPTPATH}/.data/.env"; then
                    run_script 'appvars_purge' "${APPNAME}"
                else
                    APPNAME=${APPNAME,,}
                    warn "Can't remove variables for ${APPNAME^}; it is still installed."
                fi
            done < <(grep '_ENABLED=false$' < "${SCRIPTPATH}/.data/.env")
        fi
        PROMPT=${PREPROMPT:-}
    else
        notice "${SCRIPTPATH}/.data/.env does not contain any disabled apps."
    fi
}

test_appvars_purge_all() {
    run_script 'env_update'
    run_script 'appvars_purge_all'
    cat "${SCRIPTPATH}/.data/.env"
}
