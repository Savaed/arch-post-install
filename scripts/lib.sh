#!/bin/env sh


p=$(realpath "${BASH_SOURCE}")
p="${p%/*}"
p="${p%/*}"

_install_packages_from_json() {
    config_section=$1

    if ! jq -r ".$config_section.$2[]" "$p/packages.jsonc" > /dev/null 2>&1; then
        exit
    fi

    packages=$(jq -r ".$config_section.$2[]" "$p/packages.jsonc")
    preselected=""

    for package in $packages
    do
        preselected="$preselected,$package"
    done

    selected=$(echo "$packages" | xargs gum choose --no-limit --height 50 \
        --header "Which packages to install? Skip all with CTRL-C." --selected  "$preselected")

    if [ "$selected" = "user aborted" ] || [ "$selected" = "" ]; then
        return
    fi

    if [ "$2" = "aur" ]; then
        echo "$selected" | xargs paru -S  
    fi
    if [ "$2" = "pacman" ]; then
        echo "$selected" | xargs sudo pacman --noconfirm -S  
    fi
}


install_packages_from_json() {
    section=$1
    _install_packages_from_json "$section" pacman
    _install_packages_from_json "$section" aur
}
