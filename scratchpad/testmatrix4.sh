#!/bin/bash

fio_profile_bandwidth() {
blocksizes=(8kb 16kb 1MB)
numjobs=(1 64 128 256)
iodepths=(1 64 128 256)
ioengines=(libaio io_uring)
test_types=(read write)
directs=(0 1)
}

fio_profile_iops() {
blocksizes=(4kb 8kb 16kb)
numjobs=(1 64 128 256)
iodepths=(1 64 128 256)
ioengines=(libaio io_uring)
test_types=(read write randread randrw)
directs=(0 1)
}

fio_profile_latency() {
blocksizes=4kb
numjobs=1
iodepths=1
ioengines=psync
test_types=(randread randrw)
directs=1
}

collect_fio_profile() {
unset fio_profiles
local profile
declare -ag fio_profiles

echo "fio profiles:"
for profile in $(compgen -A function fio_profile_); do
	echo "${profile}"
	fio_profiles+=("${profile}")
done
}

collect_blocksizes() {
unset combined_blocksizes
local blocksize
local profile
declare -Ag combined_blocksizes

collect_fio_profile
for profile in "${fio_profiles[@]}"; do
	export -f "${profile}"
done

declare -Ag combined_blocksizes+=$(
	declare -A combined_blocksizes
	for profile in "${fio_profile_[@]}"; do
		"${profile}"
		for blocksize in "${blocksizes[@]}"; do
			combined_blocksizes["${blocksize}"]=1
		done
	done
	echo "$(declare -p combined_blocksizes | cut -d= -f2-)"
	)
	
for profile in "${fio_profile_[@]}"; do
	export -nf "${profile}"
done
}

test_matrix_zfs() {
for blocksize in "${combined_blocksizes[@]}"; do
	zfs_create_dataset
}


































