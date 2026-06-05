#!/bin/bash

#######################################
########	 ZFS Config 	###########
#######################################

	zfs_config_declare() {
	local drive
	local sda="/dev/disk/by-id/wwn-0x5000cca04daec0b8"
	local sdb="/dev/disk/by-id/wwn-0x5000cca04db0abb8"
	local sdc="/dev/disk/by-id/wwn-0x5000cca04db11a94"
	local sdd="/dev/disk/by-id/wwn-0x5000cca04dac6d70"
	local sde="/dev/disk/by-id/wwn-0x5000cca072832eb8"
	local sdf="/dev/disk/by-id/wwn-0x5000cca0729a8b00"
	local sdg="/dev/disk/by-id/wwn-0x5000cca072837b80"
	local sdh="/dev/disk/by-id/wwn-0x5000cca07281c3c8"
	local sdi="/dev/disk/by-id/wwn-0x5000cca072844934"
	local sdj="/dev/disk/by-id/wwn-0x5000cca0728495a8"
	local sdk="/dev/disk/by-id/wwn-0x5000cca07283e2bc"
	local sdl="/dev/disk/by-id/wwn-0x5000cca072836aa8"
	local sdm="/dev/disk/by-id/wwn-0x5000c5006259e7db"

	declare -g zfs_all_drives_used="$(
	for drive in $(compgen -A variable sd); do
		printf '%s ' ${!drive}
	done
	)"

	read -ra zfs_all_drives_used <<< "${zfs_all_drives_used}"

	declare -Ag ZPOOL_LAYOUTS=(
			[SSD_4STRIPE]="12 $sda $sdb $sdc $sdd"
			[SSD_2X2RAID10]="12 mirror $sda $sdb mirror $sdc $sdd"
			[SSD_4RAIDZ1]="12 raidz1 $sda $sdb $sdc $sdd"
			[HDD_8STRIPE]="9 $sde $sdf $sdg $sdh $sdi $sdj $sdk $sdl"
			[HDD_2X4RAID10]="9 mirror $sde $sdf mirror $sdg $sdh mirror $sdi $sdj mirror $sdk $sdl"
			[HDD_2MIRROR]="9 $sde $sdf"
			[HDD_8RAIDZ2]="9 raidz2 $sde $sdf $sdg $sdh $sdi $sdj $sdk $sdl"
	)
	}
	zfs_config_declare
	declare -p zfs_all_drives_used

#######################################
########	ZFS	Functions	###########
#######################################

zfs_clear_test_drives() {
zpool export -a
wipefs -af "${zfs_all_drives_used[@]}"
blkdiscard -f "${zfs_all_drives_used[@]}" 2> /dev/null
}

zfs_disk_matrix() {
local zpool zpool_layout ashift
local -n zpool_name=disk_config
local testfile

zfs_clear_test_drives

for zpool in "${!ZPOOL_LAYOUTS[@]}"; do
	disk_config="${zpool}"
	read -r ashift zpool_layout <<<"\
		$(echo ${ZPOOL_LAYOUTS[$zpool]} | cut -d" " -f1) \
		$(echo ${ZPOOL_LAYOUTS[$zpool]} | cut -d" " -f2-) \
		"
	zfs_zpool_create
	zfs_test_matrix
done
hwraid_cleanup
}

zfs_zpool_create() {
zpool create \
-o ashift="${ashift}" \
-o autotrim=on \
-O relatime=on \
"${zpool_name}" \
"${zpool_layout}"
}

zfs_create_dataset() {
# Depends on zfs_resolve_direct()
local checksum="${checksum}"
local primarycache="${primarycache}"

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

zfs_test_matrix() {
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