#!/usr/bin/env bash


if [ ! -x "$(command -v ufw)" ]; then
    sudo pacman -S ufw
fi

# sudo ss -tupln
#
# ssh_port=$(gum input --placeholder 'input SSH port')
#
# sudo ufw allow "$ssh_port"
# sudo ufw enable
# sudo ufw status verbose

# optional deny ping 
gum confirm 'Deny ping to this machine?' && sed -i '/\#ok icmp codes for INPUT/a-A ufw-before-input -p icmp --icmp-type echo-request -j DROP/' /etc/ufw/before.rules

