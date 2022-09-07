#!/bin/bash

_base_addons() {
    pacman -U --noconfirm /home/alarm/configs/xkeyboard-config-2.35.1-1-any.pkg.tar.xz
}

_finish_up() {
    printf "alarm ALL=(ALL:ALL) NOPASSWD: ALL\n" >> /etc/sudoers
    gpasswd -a alarm wheel
    printf "exec openbox-session\n" >> /home/alarm/.xinitrc
    printf "if [ -z \"\${DISPLAY}\" ] && [ \"\${XDG_VTNR}\" -eq 1 ]; then\n  exec startx\nfi\n" >> /home/alarm/.bash_profile
    chown alarm:alarm /home/alarm/.xinitrc
    chmod 644 /home/alarm/.xinitrc
    rm -rf /endeavouros*
    systemctl disable dhcpcd.service
    systemctl enable NetworkManager.service
    pacman -Rn --noconfirm dhcpcd
    printf "\nalias ll='ls -l --color=auto'\n" >> /etc/bash.bashrc
    printf "alias la='ls -al --color=auto'\n" >> /etc/bash.bashrc
    printf "alias lb='lsblk -o NAME,FSTYPE,FSSIZE,LABEL,MOUNTPOINT'\n\n" >> /etc/bash.bashrc
    rm /var/cache/pacman/pkg/*
    rm /root/img-chroot-eos.sh
    rm /root/enosARM.log
    rm -rf /etc/pacman.d/gnupg
    # rm -rf /etc/lsb-release
    cp /home/alarm/configs/ORION-sky-ARM.png /usr/share/endeavouros/backgrounds/endeavouros-wallpaper.png
    cp /home/alarm/configs/EOS-PLANETS-ARM.png /usr/share/endeavouros/backgrounds/endeavouros-calamares-wallpaper.png
    # from old config_script.sh
    cd /home/alarm/
    rm -rf .config
    mkdir .config
    mkdir Desktop
    cd configs/
    # cp /boot/config.txt /boot/config.txt.orig
    # cp rpi4-config.txt /boot/config.txt
    cp /usr/lib/systemd/system/getty@.service /usr/lib/systemd/system/getty@.service.bak
    cp getty@.service /usr/lib/systemd/system/getty@.service
    cp clean-up.sh /usr/local/bin/clean-up.sh
    chmod +x /usr/local/bin/clean-up.sh
    cp resize-fs.service /etc/systemd/system/resize-fs.service
    cp resize-fs.sh /usr/local/bin/resize-fs.sh
    chmod +x /usr/local/bin/resize-fs.sh
    cp resize-fs.service /etc/systemd/system/resize-fs.service
    systemctl enable resize-fs.service
    ./alarmconfig.sh
    ./calamares.sh
    cd ..
    chown -R alarm .config Desktop .Xauthority
    printf "[Match]\nName=wlan*\n\n[Network]\nDHCP=yes\nDNSSEC=no\n" > /etc/systemd/network/wlan.network
    timedatectl set-ntp true
    timedatectl timesync-status
    printf "\n\n${CYAN}Your uSD is ready for creating an image.${NC}\n"
}   # end of function _finish_up


######################   Start of Script   #################################
Main() {

    PLATFORM_NAME=" "

   # Declare color variables
      GREEN='\033[0;32m'
      RED='\033[0;31m'
      CYAN='\033[0;36m'
      NC='\033[0m' # No Color

   # STARTS HERE
   dmesg -n 1 # prevent low level kernel messages from appearing during the script

   # read in platformname passed by install-image-aarch64.sh
   file="/root/platformname"
   read -d $'\x04' PLATFORM_NAME < "$file"
   file="/root/mirrors"
   read -d $'\x04' LOCAL < "$file"
   sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/g' /etc/pacman.conf
   sed -i "s|#Color|Color\nILoveCandy|g" /etc/pacman.conf
   sed -i "s|#VerbosePkgLists|VerbosePkgLists\nDisableDownloadTimeout|g" /etc/pacman.conf
   printf "\n[endeavouros]\nSigLevel = PackageRequired\nInclude = /etc/pacman.d/endeavouros-mirrorlist\n\n" >> /etc/pacman.conf

   useradd -m "alarm" -p "alarm" -u 2001
   cp -r /root/configs/ /home/alarm/

   case $PLATFORM_NAME in
     RPi64)    cp /boot/config.txt /boot/config.txt.orig
               cp /home/alarm/configs/rpi4-config.txt /boot/config.txt
               ;;
     Pinebook) sed -i 's|^MODULES=(|MODULES=(btrfs |' /etc/mkinitcpio.conf
               ;;
   esac

   _base_addons

   _finish_up
}  # end of Main

Main "$@"
