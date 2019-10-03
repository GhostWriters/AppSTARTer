#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

nzbget_post_install()
{
    info "Making ${APPNAME} executable"
    chmod u+x,g+x "${APP_PATH}/nzbget"
}
