#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

setup_appstarter_group() {
    info "Creating appstarter group."
    groupadd -f appstarter > /dev/null 2>&1 || fatal "Failed to create appstarter group."
    if [[ ${CI:-} == true ]]; then
        notice "Skipping usermod in CI."
    else
        info "Adding ${DETECTED_UNAME} to appstarter group."
        usermod -aG appstarter "${DETECTED_UNAME}" > /dev/null 2>&1 || fatal "Failed to add ${DETECTED_UNAME} to appstarter group."
    fi
}

test_setup_appstarter_group() {
    run_script 'setup_appstarter_group'
}
