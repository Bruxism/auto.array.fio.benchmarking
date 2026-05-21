#!/bin/bash

DRIVE=nvme0n1
ZPOOL_NAME=testdrive
RESULTS_DIR="/root/Results/"

BLOCKSIZES=(4kb 8kb 64kb 128kb 1M 32M)
IODEPTHS=(1 4 16 64)
NUMJOBS=(1 4 16 64)
TEST_TYPES=(read write randread randwrite readwrite randrw)
IOENGINES=(libaio io_uring psync)
SIZES=(50G)
RUNTIMES=(300)

timestamp() {
TZ='America/Chicago' \
date +%Y.%m.%d-%H.%M;
}

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

fio_function() {
#local disk_config #TODO add function for this

#local name
#local direct
#local testfile
#local blocksize
#local iodepth
#local ioengine
#local test_type
#local size
#local numjobs
#local gtod_reduce
#local runtime
#local output_name

local mem_align=512b

#local rwmixread

#local use_pareto

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

test_matrix() {
local blocksize
local iodepth
local iodepth_i
local test_type
local size
local numjobs
local direct
local use_pareto

for blocksize in "${BLOCKSIZES[@]}"; do
for direct in 0 1; do
	# Iterate through IODEPTHS and at the same time,
	# 	iterate in the reverse of NUMJOBS.
	# 	They should have the same set of numbers for simplicity.
	for ((iodepth_i=0; iodepth_i<"${#IODEPTHS[@]}"; iodepth_i++)); do
		iodepth="${IODEPTHS[iodepth_i]}"
		numjobs="${NUMJOBS[-1-iodepth_i]}"		
		for ioengine in "${IOENGINES[@]}"; do
			# If ioengine is psync, then iodepth is set to 1 by fio
			#	on the backend anyway. It also means that it's testing for
			# 	latency so it needs gtod_reduce to be off to record them.
			# This is really just for the fio_output_name function.
			# If any other test is on, then latency is probably going
			#	to be blasted by IOPS or bandwidth for measuring those, and
			#	turning it off means getting closer to maximizing performance
			#	for those metrics.
			if [[ "${ioengine}" == psync ]]; then
				iodepth=1
				gtod_reduce=0
			else
				gtod_reduce=1
			fi
			for test_type in "${TEST_TYPES[@]}"; do
			for size in "${SIZES[@]}"; do
			for runtime in "${RUNTIMES[@]}"; do
			for use_pareto in 0 1; do
				matrix_fs_case
				fio_function
			done
			done
			done
			done
		done
	done
done
done
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

matrix_fs_case() {
# Depends on ${fs} being set such as by
#	zpool_create
case "${fs}" in
	ZFS)
		setup_zfs_testfile
	;;
	ext4)
		#TODO
	;;
esac
}

setup_zfs_testfile() {
# Depends on:
# 	zfs_clear_testpool_datasets
#	prepare_zfs_testfile_dataset
# Depended by:
#	matrix_fs_case

#local previous_direct

local zpool_name="${ZPOOL_NAME}"

# If testfile exists in the intended zfs blocksize/recordsize, and
# 	direct hasn't changed, then continue to use the same dataset/testfile
#	after clearing cache/ARC and giving a little time for it to clear out
if [[ -a /"${zpool_name}"/"${blocksize}"/testfile ]] && \
	[[ -n "${previous_direct}" ]] && \
	(( "${previous_direct}" == "${direct}" ))
then
	echo "Dataset recreation unnecessary. Leaving it in place, and reusing it."
	previous_direct="${direct}"
	echo 3 > /proc/sys/vm/drop_caches
	sleep 10
else
	echo "Dataset recreation necessary. Recreating before next test."
	previous_direct="${direct}"
	zfs_clear_testpool_datasets
	prepare_zfs_testfile_dataset
fi
}

prepare_zfs_testfile_dataset() {
# Depends on: 
#	zfs_resolve_direct
#	zfs_create_dataset
# Depended by:
#	setup_zfs_testfile
local zpool_name="${ZPOOL_NAME}"

zfs_resolve_direct
zfs_create_dataset
testfile=/"${zpool_name}"/"${recordsize}"/testfile
}


mkdir -p "${RESULTS_DIR}"

# Clear any existing filesystems from previous tests
zpool_destroy "${DRIVE}" "${ZPOOL_NAME}"
delete_ext4

# Start ZFS testing
zpool_create 9 "${ZPOOL_NAME}" "${DRIVE}"
test_matrix
zpool_destroy "${DRIVE}" "${ZPOOL_NAME}"

# Start ext4 testing
make_ext4
test_matrix