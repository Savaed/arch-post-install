#!/bin/env bash

p=$(realpath "${BASH_SOURCE}")
p="${p%/*}"
. "$p/scripts/lib.sh"

check_cpu() {
    cpu=$(lscpu | grep "Model name" | tr '[:upper:]' '[:lower:]')

    case $cpu in
        *"intel"*)
            echo "intel-ucode"
            ;;
        *"amd"*)
            echo "amd-ucode"
            ;;
    esac
}

install_core_packages() {
    gum log -l info "Updating system"
    sudo pacman --noconfirm -Suy
    packages=$(jq -r .core[] "$p/packages.jsonc")
    packages="$packages $(check_cpu)"
    echo "$packages" | sudo xargs pacman --noconfirm -S   # BUG: pacman od razu konczy i nie daje wpisac y/n
}

install_aur_helper() {
    if [ -x "$(command -v paru)" ]; then
        return
    fi
    if [ -d /tmp/paru ]; then
        rm -drf /tmp/paru
    fi

    mkdir /tmp/paru
    cd /tmp/paru || exit
    git clone https://aur.archlinux.org/paru.git
    cd paru || exit
    makepkg -si
    # aur_package=$(ls -l | grep -E 'paru-bin-[0-9].*pkg.*' | awk '{print $NF}')
    # sudo pacman -U "$aur_package"
    cd /tmp || exit
    rm -drf paru
}

install_display_manager() {
    display_manager=$(gum choose "gdm" "sddm" --header "Which display manager to install?")
    if [ "$display_manager" = "" ]; then
        return
    fi

    sudo pacman --noconfirm -S "$display_manager"

    if [ "$display_manager" = "gdm" ]; then
        gum confirm "Install gdm-settings?" && sudo paru -A gdm-settings
    fi

    if systemctl list-units | grep "$display_manager" > /dev/null; then
        sudo systemctl enable "$display_manager"
    fi
}

post_intall () {
    if [ -x "$(command -v bat)" ]; then
        # Rebuild e.g. themes
        bat cache --build
    fi
}

clear

# Core setup
sudo pacman --noconfirm -S jq gum  # Packages needed for install_core_packages()
install_core_packages
sudo "$p/scripts/pacman.sh"
install_aur_helper
gum confirm "Setup bootloader (only systemd supported)?" && sudo "$p/scripts/setup-bootloader.sh"
gum confirm "Install GPU drivers?" && sudo "$p/scripts/gpu-drivers.sh"
gum confirm "Setup bluetooth?" && sudo "$p/scripts/setup-bluetooth.sh"

# Desktop setup
install_display_manager
install_packages_from_json desktop

# Development and science packages
gum confirm "Install development and science packages?" && "$p/scripts/install-dev-science.sh"

# Hyprland
gum confirm "Install hyprland packages?" && install_packages_from_json hyprland

gum confirm "Setup SHH and firewall?" && ./scripts/ssh-hardening.sh && ./scripts/firewall.sh

