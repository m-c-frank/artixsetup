#!/bin/bash

echo "SAFETY REMINDER: Please review the script thoroughly. If you are sure about the actions, uncomment or remove the 'exit' line to proceed."
exit

device="/dev/nvme0n1"

# Delete existing partition table if any
fdisk $device <<EOF
o
w
EOF
partx -u $device

# Create nvme0n1p1 of 1GB
fdisk $device <<EOF
n
p
1

+1G
w
EOF
partx -u $device

# Create nvme0n1p2 of 32GB
fdisk $device <<EOF
n
p
2

+32G
w
EOF
partx -u $device

# Create nvme0n1p3 taking up the remaining space
fdisk $device <<EOF
n
p
3


w
EOF
partx -u $device

echo "Partitions created successfully on $device."
