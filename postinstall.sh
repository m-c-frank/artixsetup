#!/bin/sh

# Define the root directory of the target system
TARGET_ROOT="/mnt/"

# Define the EFI partition mount point (Assuming it's /boot in this case)
EFI_MOUNT_POINT="/boot"

# Make sure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# Check if the target root directory exists
if [ ! -d "$TARGET_ROOT" ]; then
    echo "Target root directory $TARGET_ROOT does not exist. Please mount the target system root to $TARGET_ROOT."
    exit 1
fi

# Chroot into the target system
artix-chroot "$TARGET_ROOT" /bin/sh <<'EOT'
    # Install grub, efibootmgr, and other required tools
    pacman -S --noconfirm grub efibootmgr

    # Install GRUB for UEFI systems
    grub-install --target=x86_64-efi --efi-directory=$EFI_MOUNT_POINT --bootloader-id=GRUB

    # Generate the GRUB configuration file
    grub-mkconfig -o /boot/grub/grub.cfg

    # Navigate to /tmp/so and list the files
    if [ -d "/tmp/so" ]; then
        cd /tmp/so
        ls -l
    else
        echo "/tmp/so directory does not exist."
    fi

    # Print the current process ID
    echo "Current PID: $$"
EOT

echo "Script execution completed."
