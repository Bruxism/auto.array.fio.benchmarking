#!/bin/bash

# TODO
#	Add disk configuration automation
#		for hardware RAID
#		for ZFS
#		Includes naming function adaptation
# 
#
#
#
#
#
#
#

ZPOOL_NAME=testdrive
RESULTS_DIR="/root/Results/"

SIZES=(50G)
RUNTIMES=(300)

#######################################
########	Profiles	###############
#######################################
fio_profile_bandwidth() {
blocksizes=(8kb 16kb 1MB)
numjobss=(1 2 4 64 128 256)
iodepths=(1 2 4 64 128 256)
ioengines=(libaio io_uring)
test_types=(read write)
directs=(0 1)
use_paretos=(0 1)
}

fio_profile_iops() {
blocksizes=(4kb 8kb 16kb)
numjobss=(1 2 4 64 128 256)
iodepths=(1 2 4 64 128 256)
ioengines=(libaio io_uring)
test_types=(read write randread randrw)
directs=(0 1)
use_paretos=(0 1)
}

fio_profile_latency() {
blocksizes=4kb
numjobss=1
iodepths=1
ioengines=psync
test_types=(randread randrw)
directs=1
use_paretos=(0)
}

#######################################
########	Collect	Functions	#######
#######################################

collect_fio_profiles() {
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

collect_fio_profiles
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


#######################################
########	fio	Functions	###########
#######################################



fio_function() {
#local disk_config #TODO add function for this

local mem_align=512b

local args=(
	--filename="${testfile}"
	--bs="${blocksize}"
	--iodepth="${iodepth}"
	--ioengine="${ioengine}"
	--rw="${test_type}"
	--size="${size}"
	--numjobs="${numjobs}"
	--gtod_reduce="${gtod_reduce}"
	--group_reporting
	--time_based
	--mem_align="${mem_align}"
	--end_fsync=1
	--direct="${direct}"
	--runtime="${runtime}"
	--output-format=normal,json
	)
	
if [[ "${use_pareto}" == "1" ]]; then
	args+=( 
		--norandommap=1
		--random_distribution=pareto:0.8
		)
fi

case "${test_type}" in
	randrw|readwrite|rw)
		args+=(--rwmixread=80)
		rwmixread=80
	;;
	*)
		unset rwmixread # Used for fio_output_name()
	;;
esac

fio_output_name
args+=(--output="${output_name}".log)
args+=(--name="fiotest")

echo "${args[@]}"

fio "${args[@]}"
}

fio_output_name() {
unset extra_info

case "${fs}" in
	ZFS)
		# TODO needs work for automation of varying configurations
		#	It would probably be something set up at the top of the script
		#	where disk configurations are declared to be iterated over for
		#	testing.
		disk_config="${DRIVE}"."${fs}"0.rs-"${recordsize}"
	;;
	ext4)
		disk_config="${DRIVE}"."${fs}"
	;;
esac

if [[ -n mem_align ]]; then
	extra_info+=".mem_align-${mem_align}"
fi
if [[ "${use_pareto}" == "1" ]]; then
	extra_info+=".pareto-.8"
fi

output_name="${RESULTS_DIR}"
output_name+="${disk_config}"
output_name+=".direct-${direct}"
output_name+=".${ioengine}"
output_name+=".${test_type}"
output_name+="${rwmixread:+.rwmixread-${rwmixread}}"
output_name+=".bs-${blocksize}"
output_name+=".iodepth-${iodepth}"
output_name+=".numjobs-${numjobs}"
output_name+=".size-${size}"
output_name+="${extra_info:+${extra_info}}"
output_name+=".$(timestamp)"
}






























