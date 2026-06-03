#!/bin/bash

#######################################
########	Ext4 Functions	###########
#######################################

make_ext4() {
parted --script /dev/disk/by-id/"${disk}" mklabel gpt mkpart "" ext4 0% 100%
sleep 1
mkfs.ext4 -F /dev/disk/by-id/"${disk}"-part1 -E lazy_itable_init=0,lazy_journal_init=0
sleep 1
mkdir -p /mnt/"${disk}"
mount -o noatime,nodiratime /dev/disk/by-id/"${disk}"-part1 /mnt/"${disk}"
testfile=/mnt/"${disk}"/testfile
}

delete_ext4() {
umount /mnt/"${disk}"
wipefs -af /dev/disk/by-id/"${disk}"
sleep 1
blkdiscard -f /dev/disk/by-id/"${disk}" 2> /dev/disk/by-id/null
sleep 1
}