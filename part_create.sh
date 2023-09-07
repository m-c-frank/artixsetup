#!/bin/bash

echo "SAFETY REMINDER: Please review the script thoroughly. If you are sure about the actions, uncomment or remove the 'exit' line to proceed."
exit

device="/dev/nvme0n1"

lsblk
fdisk $device <<EOF
o
w
EOF

lsblk
sleep 1
fdisk $device <<EOF
n
p
1

+1G
w
EOF

lsblk
wait -n
partx -u $device
sleep 1
fdisk $device <<EOF
n
p
2

+32G
w
EOF

lsblk
wait -n
partx -u $device
sleep 1
fdisk $device <<EOF
n
p
3


w
EOF


echo "Partitions created successfully on $device."
wait -n
partx -u $device
wait -n
sync
sleep 1
lsblk