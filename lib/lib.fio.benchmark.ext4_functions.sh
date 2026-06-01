#!/bin/bash

#######################################
########	Ext4 Functions	###########
#######################################

make_ext4() {
fs=ext4

parted --script /dev/"${DRIVE}" mklabel gpt mkpart "" ext4 0% 100%
mkfs.ext4 -F /dev/"${DRIVE}"p1 -E lazy_itable_init=0,lazy_journal_init=0
mkdir -p /mnt/"${DRIVE}"
mount -o noatime,nodiratime /dev/"${DRIVE}"p1 /mnt/"${DRIVE}"
testfile=/mnt/"${DRIVE}"/testfile
}

delete_ext4() {
unset fs

umount /mnt/"${DRIVE}"
wipefs -af /dev/"${DRIVE}"
sleep 1
blkdiscard -f /dev/"${DRIVE}"
sleep 1
}