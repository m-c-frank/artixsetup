#!/bin/bash

# Constants
DEVICE="/dev/nvme0n1"

# Clear the partition table
clear_partition_table() {
    if ! fdisk $1 <<EOF
o
w
EOF
    then
        echo "Failed to clear the partition table on $1."
        exit 1
    fi
}

# Create a partition
create_partition() {
    local device=$1
    local type=$2
    local number=$3
    local size=$4

    if ! fdisk $device <<EOF
n
$type
$number

$size
w
EOF
    then
        echo "Failed to create partition $number on $device."
        exit 1
    fi
}

# Format a partition
format_partition() {
    local partition=$1
    local fs_type=$2

    case "$fs_type" in
        "fat32")
            mkfs.vfat -F 32 $partition || { echo "Failed to format $partition as FAT32."; exit 1; }
            ;;
        "ext4")
            mkfs.ext4 $partition || { echo "Failed to format $partition as ext4."; exit 1; }
            ;;
        *)
            echo "Unsupported file system type: $fs_type"
            exit 1
            ;;
    esac
}

# Update the OS with partition table changes
update_partitions() {
    local device=$1
    local retry_count=0

    until partx -u $device; do
        retry_count=$((retry_count+1))
        if [ "$retry_count" -ge 3 ]; then
            echo "Failed to update partitions on $device after multiple attempts."
            exit 1
        fi

        echo "Retrying to update partitions..."
        sleep 1
    done
}

# Mount partitions and create directories
mount_and_create_dirs() {
    mount "${DEVICE}p2" /mnt && {
        mkdir -p /mnt/home
        mkdir -p /mnt/boot
    } || {
        echo "Failed to mount or create directories on ${DEVICE}p2."
        exit 1
    }

    mount "${DEVICE}p1" /mnt/boot || { echo "Failed to mount ${DEVICE}p1 on /mnt/boot."; exit 1; }
    mount "${DEVICE}p3" /mnt/home || { echo "Failed to mount ${DEVICE}p3 on /mnt/home."; exit 1; }
}

post_install() {
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
}

chroot_and_post_install() {
    # Mount necessary filesystems for chroot environment
    mount -t proc proc /mnt/proc
    mount -t sysfs sys /mnt/sys
    mount -o bind /dev /mnt/dev
    mount -o bind /run /mnt/run   # This might be needed for networking within the chroot

    # Enter the chroot and run the post_install function
    arch-chroot /mnt /bin/bash -c "$(declare -f post_install); post_install"

    # Unmount filesystems after exiting chroot
    umount /mnt/{proc,sys,dev,run}
}

# Main function
main() {
    # Display current block devices
    lsblk

    # Clear the partition table
    clear_partition_table $DEVICE

    # Display updated block devices
    lsblk

    # Create partitions and update OS
    create_partition $DEVICE "p" "1" "+1G"
    update_partitions $DEVICE

    create_partition $DEVICE "p" "2" "+32G"
    update_partitions $DEVICE

    create_partition $DEVICE "p" "3" ""
    update_partitions $DEVICE

    # Format the partitions
    format_partition "${DEVICE}p1" "fat32"
    format_partition "${DEVICE}p2" "ext4"
    format_partition "${DEVICE}p3" "ext4"

    # Confirm the partitions were created and formatted successfully
    echo "Partitions created and formatted successfully on $DEVICE."

    # Flush file system buffers
    sync

    # Display the final block devices list
    lsblk

    # Mount partitions and create directories
    mount_and_create_dirs

    basestrap /mnt base base-devel runit elogind-runit linux linux-firmware

    fstabgen -U /mnt >> /mnt/etc/fstab

    # Chroot and perform post installation tasks
    chroot_and_post_install
}

# Execute the main function
main
