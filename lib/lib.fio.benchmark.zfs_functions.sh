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
for blocksize in "${!combined_blocksizes[@]}"; do
for profile in "${fio_profiles[@]}"; do
	"${profile}"
	[[ " ${blocksizes[@]} " =~ " ${blocksize} " ]] || continue
	for direct in "${directs[@]}"; do
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