#!/bin/bash

# Constants
device="/dev/nvme0n1"

# Function to display a safety reminder
safety_reminder() {
    echo "SAFETY REMINDER: Please review the script thoroughly."
    echo "If you are sure about the actions, uncomment or remove the 'exit' line to proceed."
    exit
}

# Function to clear the partition table
clear_partition_table() {
    fdisk $1 <<EOF
o
w
EOF
}

# Function to create a partition
create_partition() {
    local device=$1
    local type=$2
    local number=$3
    local size=$4

    fdisk $device <<EOF
n
$type
$number

$size
w
EOF
}

# Function to format a partition
format_partition() {
    local partition=$1
    local fs_type=$2

    if [ "$fs_type" == "fat32" ]; then
        mkfs.vfat -F 32 $partition
    elif [ "$fs_type" == "ext4" ]; then
        mkfs.ext4 $partition
    else
        echo "Unsupported file system type: $fs_type"
        exit 1
    fi
}

# Function to update the OS with partition table changes and ensure the command is successful
update_partitions() {
    local device=$1

    until partx -u $device; do
        echo "Retrying to update partitions..."
        sleep 1
    done
}

# Main script execution
safety_reminder

# Display current block devices
lsblk

# Clear the partition table
clear_partition_table $device

# Display updated block devices
lsblk

# Create partitions and update OS
create_partition $device "p" "1" "+1G"
update_partitions $device

create_partition $device "p" "2" "+32G"
update_partitions $device

create_partition $device "p" "3" ""
update_partitions $device

# Format the partitions
format_partition "${device}p1" "fat32"
format_partition "${device}p2" "ext4"
format_partition "${device}p3" "ext4"

# Confirm the partitions were created and formatted successfully
echo "Partitions created and formatted successfully on $device."

# Flush file system buffers
sync

# Display the final block devices list
lsblk
