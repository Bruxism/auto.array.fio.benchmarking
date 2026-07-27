#!/bin/bash

#######################################
########	Ext4 Functions	###########
#######################################

raw_prep() {
testfile="${testdisk_by_id}"

echo "testfile path: ${testdisk_by_id}"

wipefs -af "${testdisk_by_id}"
sleep 1
blkdiscard -f "${testdisk_by_id}" 2> /dev/null
}

raw_delete() {
sleep 1
wipefs -af "${testdisk_by_id}"
sleep 1
blkdiscard -f "${testdisk_by_id}" 2> /dev/null
sleep 1
}

raw_disk_matrix() {
local disk_name testdisk_by_id
local test_partition
local test_mountdir
local testfile
local disk_config
local results_dir="${RESULTS_DIR}/raw"

mkdir -p "${results_dir}"

sleep 1
for disk_name in "${!RAW_LAYOUTS[@]}"; do
	disk_config="${disk_name}"
	testdisk_by_id="${RAW_LAYOUTS[${disk_name}]}"
	raw_prep
	raw_test_matrix
	raw_delete
done
}

raw_test_matrix() {
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