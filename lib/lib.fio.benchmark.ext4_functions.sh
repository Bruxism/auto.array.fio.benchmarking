#!/bin/bash

#######################################
########	Ext4 Functions	###########
#######################################

ext4_make() {
test_mountdir="/mnt/fiotestmount"
test_partition="${testdisk_by_id}-part1"
testfile="${test_mountdir}/testfile"

echo "testfile path: ${testfile}"

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
sleep 1
rm -rf "${test_mountdir}"
wipefs -af "${test_partition}"
wipefs -af "${testdisk_by_id}"
sleep 1
blkdiscard -f "${testdisk_by_id}" 2> /dev/null
sleep 1
}

ext4_disk_matrix() {
local disk_name testdisk_by_id
local test_partition
local test_mountdir
local testfile
local disk_config
local results_dir="${RESULTS_DIR}/ext4"

mkdir -p "${results_dir}"

sleep 1
for disk_name in "${!EXT4_LAYOUTS[@]}"; do
	disk_config="${disk_name}"
	testdisk_by_id="${EXT4_LAYOUTS[${disk_name}]}"
	wipefs -af "${testdisk_by_id}"
	ext4_make
	ext4_test_matrix
	ext4_delete
done
}

ext4_test_matrix() {
local iodepth_numjob

for profile in "${fio_profiles[@]}"; do
	"${profile}"
	for direct in "${directs[@]}"; do
	for blocksize in "${blocksizes[@]}"; do
		for iodepth_numjob in "${iodepths_numjobs[@]}"; do
			IFS="," read -r iodepth numjobs <<< "$(echo "${iodepth_numjob}")"
			for ioengine in "${ioengines[@]}"; do
			for test_type in "${test_types[@]}"; do
			for size in "${SIZES[@]}"; do
			for runtime in "${RUNTIMES[@]}"; do
			for use_pareto in "${use_paretos[@]}"; do
				fio_function
			done
			done
			done
			done
			done
		done
	done
	done
done
}