#!/bin/env sh


p=$(realpath "${BASH_SOURCE}")
p="${p%/*}"
. "$p/lib.sh"


replace_calculators() {
    if pacman -Qi gnome-calculator > /dev/null && pacman -Qi qalculate-gtk > /dev/null; then
        gum log -l info "Gnome calculator and Qalculate detected"
        calculator_to_delete="$(gum choose 'gnome-calculator' 'qalculate-gtk' --header 'Which one to remove? Skip with CTRL-C')"

        if [ "$calculator_to_delete" = "user aborted" ]; then
            return
        fi

        sudo pacman -Rs "$calculator_to_delete"
    fi
}

install_packages_from_json dev_science
replace_calculators
