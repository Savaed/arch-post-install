#!/usr/bin/env bash


ssh_port=$(gum input --width 0 --header 'Provide SHH port (default to 22): ')

if [ "$ssh_port" != "" ];then
    sudo sed 's/Port 22/Port XXX/' -i /etc/ssh/sshd_config
fi

sudo sed -i 's/\#AddressFamily.*/AddressFamily inet/' /etc/ssh/sshd_config
sudo sed -i 's/PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
