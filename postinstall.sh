#!/bin/sh

EFI_MOUNT_POINT="/boot"

# Install grub, efibootmgr, and other required tools
pacman -S --noconfirm grub efibootmgr

# Install GRUB for UEFI systems
grub-install --target=x86_64-efi --efi-directory=$EFI_MOUNT_POINT --bootloader-id=GRUB

# Generate the GRUB configuration file
grub-mkconfig -o /boot/grub/grub.cfg

ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime

hwclock --systohc

pacman -S --noconfirm github-cli wpa_supplicant wpa_supplicant-runit dhclient

curl -LO https://raw.githubusercontent.com/m-c-frank/artixsetup/main/larbs.sh

echo "GRUB configured. Now run the larbs script"
