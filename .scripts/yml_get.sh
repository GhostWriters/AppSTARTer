#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

yml_get() {
    local APPNAME=${1:-}
    local GET_VAR=${2:-}
    local FILENAME=${APPNAME,,}
    run_script 'install_yq'
    local YML_COUNT
    #shellcheck disable=SC2012
    YML_COUNT=$(ls -1q "${SCRIPTPATH}/.apps/${FILENAME}/"*.yml | wc -l)
    if [[ ${YML_COUNT} == 1 ]]; then
        /usr/local/bin/yq-go r "${SCRIPTPATH}/.apps/${FILENAME}/${FILENAME}.yml" "${GET_VAR}" 2> /dev/null | grep -v '^null$' || return 1
    else
        /usr/local/bin/yq-go m "${SCRIPTPATH}"/.apps/"${FILENAME}"/*.yml 2> /dev/null | /usr/local/bin/yq-go r - "${GET_VAR}" 2> /dev/null | grep -v '^null$' || return 1
    fi
}

test_yml_get() {
    run_script 'yml_get' BAZARR "services.bazarr.labels[com.appstarter.appinfo.nicename]"
}
