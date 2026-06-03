#!/bin/bash

#######################################
########	Ext4 Functions	###########
#######################################

ext4_make() {
test_mountdir="/mnt/fiotestmount"
test_partition="${testdisk_by_id}-part1"
testfile="${test_mountdir}/testfile"

echo "${testfile}"

wipefs -af "${testdisk_by_id}"
sleep 1
parted --script "${testdisk_by_id}" mklabel gpt mkpart "" ext4 0% 100%
sleep 1
mkfs.ext4 -F "${test_partition}" -E lazy_itable_init=0,lazy_journal_init=0
sleep 1
mkdir -p "${test_mountdir}"
mount -o noatime,nodiratime "${test_partition}" "${test_mountdir}"
}

ext4_delete() {
umount "${test_mountdir}"
rm -rf "${test_mountdir}"
wipefs -af "${testdisk_by_id}"
sleep 1
blkdiscard -f "${testdisk_by_id}" 2> /dev/null
sleep 1
}