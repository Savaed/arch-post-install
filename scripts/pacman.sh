#!/bin/sh


PACMAN_CONFIG=/etc/pacman.conf
PACMAN_CONFIG_DIR=/etc/pacman.d

cp $PACMAN_CONFIG $PACMAN_CONFIG.bak
cp $PACMAN_CONFIG_DIR/mirrorlist $PACMAN_CONFIG_DIR/mirrorlist.bak

sed -i "s/#Color/Color/" $PACMAN_CONFIG
sed -i "s/#ParallelDownload/ParallelDownload/" $PACMAN_CONFIG

echo ""
multilibs=$(gum choose "core-testing" "extra-testing" "multilib" "multilib-testing" --no-limit --header "Choose repos to enable. Skip with CTRL-C")

echo "$multilibs" | while read -r multilib
do
    sed -i "/\[$multilib\]/aInclude = \/etc\/pacman\.d\/mirrorlist" $PACMAN_CONFIG
    sed -i "s/#\[$multilib\]/\[$multilib\]/" $PACMAN_CONFIG
done

gum spin --spinner dot --title 'Checking for faster pacman mirrors...' -- sudo reflector --verbose --latest 10 --protocol https --sort rate --save $PACMAN_CONFIG_DIR/mirrorlist
# cat $PACMAN_CONFIG_DIR/mirrorlist
gum log -l info 'pacman speeded up'
