#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

menu_main() {
    local MAINOPTS=()
    MAINOPTS+=("Configuration " "Setup and start applications")
    MAINOPTS+=("Install Dependencies " "Latest version of all dependencies for ${APPLICATION_NAME}")
    MAINOPTS+=("Update ${APPLICATION_NAME} " "Get the latest version of ${APPLICATION_NAME}")
    #MAINOPTS+=("Backup Configs " "Create band of app config folders")

    local MAINCHOICE
    if [[ ${CI:-} == true ]]; then
        MAINCHOICE="Cancel"
    else
        MAINCHOICE=$(whiptail --fb --clear --title "${APPLICATION_NAME}" --cancel-button "Exit" --menu "What would you like to do?" 0 0 0 "${MAINOPTS[@]}" 3>&1 1>&2 2>&3 || echo "Cancel")
    fi

    case "${MAINCHOICE}" in
        "Configuration ")
            run_script 'menu_config' || run_script 'menu_main'
            ;;
        "Install Dependencies ")
            run_script 'run_install' || run_script 'menu_main'
            ;;
        "Update ${APPLICATION_NAME} ")
            run_script 'update_self' || run_script 'menu_main'
            ;;
        "Backup Configs ")
            run_script 'menu_backup' || run_script 'menu_main'
            ;;
        "Cancel")
            info "Exiting ${APPLICATION_NAME}."
            return
            ;;
        *)
            error "Invalid Option"
            ;;
    esac
}

test_menu_main() {
    # run_script 'menu_main'
    warn "CI does not test menu_main."
}
