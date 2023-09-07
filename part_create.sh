#!/bin/bash

# SAFETY MEASURE: Uncomment or remove the next line after reviewing the script.
exit

device="/dev/nvme0n1"

# Create nvme0n1p1 of 1GB
sudo fdisk $device <<EOF
n
p
1

+1G
w
EOF

# Create nvme0n1p2 of 32GB
sudo fdisk $device <<EOF
n
p
2

+32G
w
EOF

# Create nvme0n1p3 taking up the remaining space
sudo fdisk $device <<EOF
n
p
3


w
EOF

echo "Partitions created successfully on $device."
