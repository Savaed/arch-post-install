#!/bin/sh


p=$(dirname "$0")

setup_nvidia() {
    nvidia_drivers_version=$1
    linux_version=$2
    NVIDIA_MODPROB_PATH="/etc/modprobe.d/nvidia.conf"
    
    if [ -f "$NVIDIA_MODPROB_PATH" ]; then
        cp "$NVIDIA_MODPROB_PATH" "$NVIDIA_MODPROB_PATH.bak"
    fi
    
    echo "options nvidia_drm modeset=1 fbdev=1 options nvidia NVreg_TemporaryFilePath=/var/tmp NVreg_PreserveVideoMemoryAllocations=1" >> "$NVIDIA_MODPROB_PATH"

    MKINITCPIO_PATH="/etc/mkinitcpio.conf"
    cp "$MKINITCPIO_PATH" "$MKINITCPIO_PATH.bak"

    # Remove kms module
    sed -i "s/kms//" "$MKINITCPIO_PATH"

    # Add nvidia modules
    sed -i "/MODULES=(usb/aMODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)" "$MKINITCPIO_PATH"

    # Add pacman hook for nvidia
    NVIDIA_HOOK_PATH="/etc/pacman.d/hooks/nvidia.hook.bak"

    if [ -f "$NVIDIA_HOOK_PATH" ]; then
        cp "$NVIDIA_HOOK_PATH" "$NVIDIA_HOOK_PATH.bak"
    fi

    cp "$p/nvidia-pacman-hook.tpl" "$NVIDIA_HOOK_PATH"
    sed -i "s/{nvidia}/$nvidia_drivers_version/" "$NVIDIA_HOOK_PATH"
    sed -i "s/{linux}/$linux_version/" "$NVIDIA_HOOK_PATH"

    # Regenerate initramfs
    if [ -x "$(command -v mkinitcpio)" ]; then
        if gum confirm "Rgenerate initramfs"; then
            cp -r /boot /boot.bak  # WARN: moze byc inny katalog niz /boot
            mkinitcpio -P || echo ""
        fi
    fi

    # Enable systemd power managment
    if gum confirm "Enable nvidia-suspend/resume/hibernate services?"; then
        gum spin --spinner dot -- systemctl enable nvidia-resume &&
        systemctl enable nvidia-suspend &&
        systemctl enable nvidia-hibernate
    fi
}


# Only nvidia supported for now
if lspci | grep "VGA.*NVIDIA" 2> /dev/null; then
    gum log -l info "NVIDIA GPU detected"

    if gum confirm "Install NVIDIA drivers?"; then
        nvidia_version=$(gum choose "nvidia" "nvidia-lts" "nvidia-open")
        pacman -S "$nvidia_version" nvidia-utils nvidia-settings

        if gum confirm "Setup NVIDIA?"; then 
            linux_version=$(gum choose "linux" "linux-lts")
            setup_nvidia "$nvidia_version" "$linux_version"
        fi
    else
        echo "no installing"
    fi

    exit 0
fi

exit 1

