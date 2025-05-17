#!/usr/bin/env bash


ssh_port=$(gum input --width 0 --header 'Provide SHH port (default to 22): ')


if ! [ -f "$NVIDIA_MODPROB_PATH" ] ; then
    sudo touch /etc/ssh/sshd_config
fi

if [ "$ssh_port" != "" ];then
    sudo sed 's/Port 22/Port XXX/' -i /etc/ssh/sshd_config
fi

sudo sed -i 's/\#AddressFamily.*/AddressFamily inet/' /etc/ssh/sshd_config
sudo sed -i 's/PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
gum log -l info "SSH hardened. If you want to use SHH please enable sshd deamon"
