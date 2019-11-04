#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

menu_app_select() {
    run_script 'install_yq'
    local APPLIST=()

    while IFS= read -r line; do
        local APPNAME=${line^^}
        local FILENAME=${APPNAME,,}
        if [[ ${FILENAME} == "template" ]]; then
            continue
        fi
        if [[ -d ${SCRIPTPATH}/.apps/${FILENAME}/ ]]; then
            if [[ -f ${SCRIPTPATH}/.apps/${FILENAME}/${FILENAME}.yml ]]; then
                if [[ -f ${SCRIPTPATH}/.apps/${FILENAME}/${FILENAME}.yml ]]; then
                    local APPNICENAME
                    APPNICENAME=$(run_script 'yml_get' "${APPNAME}" "services.${FILENAME}.labels[com.appstarter.appinfo.nicename]" || echo "${APPNAME}")
                    local APPDESCRIPTION
                    APPDESCRIPTION=$(run_script 'yml_get' "${APPNAME}" "services.${FILENAME}.labels[com.appstarter.appinfo.description]" || echo "! Missing description !")
                    if echo "${APPDESCRIPTION}" | grep -q '(DEPRECATED)'; then
                        continue
                    fi
                    local APP_NOLIST
                    APP_NOLIST=$(run_script 'yml_get' "${APPNAME}" "services.${FILENAME}.labels[com.appstarter.appinfo.nolist]" || true)
                    if [[ ${APP_NOLIST} != "" ]]; then
                        continue
                    fi
                    local APPONOFF
                    if [[ $(run_script 'env_get' "${APPNAME}_ENABLED") == true ]]; then
                        APPONOFF="on"
                    else
                        APPONOFF="off"
                    fi
                    APPLIST+=("${APPNICENAME}" "${APPDESCRIPTION}" "${APPONOFF}")
                fi
            fi
        fi
    done < <(ls -A "${SCRIPTPATH}/.apps/")

    local SELECTEDAPPS
    if [[ ${CI:-} == true ]]; then
        SELECTEDAPPS="Cancel"
    else
        SELECTEDAPPS=$(whiptail --fb --clear --title "${APPLICATION_NAME}" --separate-output --checklist 'Choose which apps you would like to install:\n Use [up], [down], and [space] to select apps, and [tab] to switch to the buttons at the bottom.' 0 0 0 "${APPLIST[@]}" 3>&1 1>&2 2>&3 || echo "Cancel")
    fi
    if [[ ${SELECTEDAPPS} == "Cancel" ]]; then
        return 1
    else
        info "Disabling all apps."
        while IFS= read -r line; do
            local APPNAME=${line%%_ENABLED=true}
            run_script 'env_set' "${APPNAME}_ENABLED" false
        done < <(grep '_ENABLED=true$' < "${SCRIPTPATH}/.data/.env")

        info "Enabling selected apps."
        while IFS= read -r line; do
            local APPNAME=${line^^}
            if [[ ${APPNAME} != "" ]]; then
                run_script 'appvars_create' "${APPNAME}"
                run_script 'env_set' "${APPNAME}_ENABLED" true
            fi
        done < <(echo "${SELECTEDAPPS}")

        run_script 'app_uninstall_all'
        run_script 'appvars_purge_all'
        run_script 'env_update'
    fi
}

test_menu_app_select() {
    # run_script 'menu_app_select'
    warn "CI does not test menu_app_select."
}
