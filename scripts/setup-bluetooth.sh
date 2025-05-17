#!/bin/sh


p=$(dirname "$0")

if ! pacman -Q bluez bluez-utils > /dev/null; then
    pacman -S bluez bluez-utils
fi

if ! lsmod | grep btusb > /dev/null; then
    exit 1
fi

sudo usermod -aG lp "$USER"
sudo systemctl enable bluetooth
sudo systemctl start bluetooth

if ! systemctl list-units | grep bluetooth > /dev/null; then
    exit 1
fi

gum format < "$p/bluetooth_commands.md"
bluetoothctl
