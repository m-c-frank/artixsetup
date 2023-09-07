#!/bin/bash

# SAFETY MEASURE: Uncomment or remove the next line after reviewing the script.
exit

device="/dev/nvme0n1" # Replace with your device name

partitions=$(sudo fdisk -l $device | grep '^/dev' | awk '{print $1}')

for partition in $partitions; do
    echo "Deleting $partition..."
    sudo fdisk $device <<EOF
d
w
EOF
done

echo "All partitions on $device have been deleted."