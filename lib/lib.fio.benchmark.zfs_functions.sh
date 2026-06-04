#!/bin/bash

#######################################
########	ZFS	Functions	###########
#######################################

zpool_destroy() {
local drive="$1"
local zpool_name="$2"

unset fs
zpool import -a
zpool destroy "${zpool_name}"
wipefs -af /dev/"${drive}"
blkdiscard -f /dev/"${drive}"
}

zpool_create() {
local ashift="$1"
local zpool_name="$2"
local drive="$3"

fs=ZFS
zpool create \
-o ashift="${ashift}" \
-o autotrim=on \
-O relatime=on \
"${zpool_name}" \
/dev/"${drive}"
}

zfs_create_dataset() {
# Depends on zfs_resolve_direct()
local checksum="${checksum}"
local primarycache="${primarycache}"
local zpool_name="${ZPOOL_NAME}"

recordsize="${blocksize}"

zfs create \
-o recordsize="${recordsize}" \
-o logbias=latency \
-o checksum="${checksum}" \
-o compression=lz4 \
-o primarycache="${primarycache}" \
-o xattr=sa \
-o atime=off \
"${zpool_name}"/"${recordsize}"
}

zfs_clear_testpool_datasets() {
local zpool_name="${ZPOOL_NAME}"

zfs destroy -r "${zpool_name}"
}

zfs_resolve_direct() {
# Depends on test_matrix()
# Depended by zfs_create_dataset()

#local direct
#local checksum
#local primarycache

case "${direct}" in
	1)
		checksum=off
		primarycache=metadata
	;;
	0)
		checksum=on
		primarycache=all
	;;
esac
}

test_matrix_zfs() {
# blocksize and direct will determine what options datasets will be created
#	because those are the primary parameters that chokes or slows down
#	testfile creation/iteration, and the testfile has to be recreated
#	each time any time either are set or changed because it changes how
#	datasets are created--blocksize becomes the recordsize and the value of
#	direct determines the values of checksum/primarycache
# Since it can take a long time to recreate the testfile, minimizing the
#	frequency of that process is accomplished by doing the following:
# First, all blocksizes are collected from all profiles and combined into
#	one variable
# Then, the matrix starts iterating though a for-loop of these combined
#	list of blocksize, and then and immediately iterates through a for-loop of
#	direct as either 1 or 0
# Then, it compares the existence of those iterating sets of blocksize and direct
#	to see if those exist in the profile being iterated, so that if those don't,
#	that part of the iteration/loop is skipped/continued
# This way, all blocksizes are iterated and tested for in their respective,
#	profiles, and datasets are only recreated when all tests for the values of
#	blocksize and direct shared in all profiles are completed
for blocksize in "${!combined_blocksizes[@]}"; do
for direct in 1 0; do
for profile in "${fio_profiles[@]}"; do
	"${profile}"
	# Skip profiles that don't have matching blocksize
	[[ " ${blocksizes[@]} " =~ " ${blocksize} " ]] || continue
	# Skip profiles that don't have matching direct
	[[ " ${directs[@]} " =~ " ${direct} " ]] || continue
	zfs_clear_testpool_datasets
	zfs_resolve_direct
	zfs_create_dataset
	for ((iodepth_i=0; iodepth_i<"${#iodepths[@]}"; iodepth_i++)); do
		iodepth="${iodepths[iodepth_i]}"
		numjobs="${numjobss[-1-iodepth_i]}"
		for ioengine in "${ioengines[@]}"; do
			if [[ "${ioengine}" == psync ]]; then
				gtod_reduce=0
			else
				gtod_reduce=1
			fi
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