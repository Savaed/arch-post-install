#!/bin/sh


p=$(dirname "$0")

gum style \
	--foreground 212 --border-foreground 212 --border normal \
	--align center --width 50 --margin "1 2" --padding "2 4" \
    "Setup EFI bootloader" "Currently ONLY systemd is supported!"

root_dir="$(lsblk -l | gum filter | awk '{print $1}')"
is_boot_dir_ok=false

while ! "$is_boot_dir_ok" 
do
    boot_dir=$(gum input --header "Type your booting directory eg. /boot")
    if [ ! -d "$boot_dir" ];then
        gum log -l error "$boot_dir is not a directory"
    else
        is_boot_dir_ok=true
    fi
done

cp "$p/arch.tpl" arch.conf
microcodes="$(pacman -Qs ucode)"
case $microcodes in
    *"intel"*)
        sed -i 's/{cpu-microcode}/initrd\tintel-ucode.img/' arch.conf
        ;;
    *"amd"*)
        echo "amd"
        sed -i 's/{cpu-microcode}/initrd\tamd-ucode.img/' arch.conf
        ;;
esac

if [ -n "${microcodes+x}" ]; then
    sed -i "s/{cpu-microcode}//" arch.conf
fi

sed -i "s/{root_dir}/$root_dir/" arch.conf
cp arch.conf "$boot_dir/loader/entries/arch.conf"
rm arch.conf

cp -r "$boot_dir" "$boot_dir.bak"
cd "$boot_dir" || exit
bootctl install
bootctl list
bootctl status
