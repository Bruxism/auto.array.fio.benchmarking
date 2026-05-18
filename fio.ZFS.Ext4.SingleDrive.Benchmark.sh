#!/bin/bash

DRIVE=nvme0n1
ZPOOL_NAME=testdrive
RESULTS_DIR="/root/Results/"


BLOCKSIZES=(4kb 8kb 16kb 64kb 128kb 1M 32M)
IODEPTHS=(1 4 8 16 32 64 128 512)
NUMJOBS=(1 4 8 16 32 64 128 512)
TEST_TYPES=(read write trim randread randwrite readwrite randrw)
IOENGINES=(libaio io_uring psync)
SIZES=(50G)
RUNTIMES=(600)

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

fs=zfs
zpool create \
-o ashift="${ashift}" \
-o autotrim=on \
-O relatime=on \
"${zpool_name}" \
/dev/"${drive}"
}

zfs_create_dataset() {
local recordsize="$1"
local checksum="$2"
local compression="$4"
local primarycache="$5"

zfs create \
-o recordsize="${recordsize}" \
-o checksum="${checksum}" \
-o logbias=latency \
-o checksum="${checksum}" \
-o compression="${compression}" \
-o primarycache="${primarycache}" \
-o xattr=sa \
-o atime=off \
"${ZPOOL_NAME}"/"${blocksize}"
}

zfs_clear_testpool() {
zfs destroy -r "${ZPOOL_NAME}"
}

zfs_resolve_profile() {
local direct
local checksum
local primarycache

zfs_resolve_direct	



}

fio_output_name() {
output_name="${RESULTS_DIR}"
output_name+="${disk_config}"
output_name+=".direct-${direct}"
output_name+=".${ioengine}"
output_name+=".${test_type}"
output_name+="${rwmixread:+.rwmixread-${rwmixread}}"
output_name+=".bs-${bs}"
output_name+=".iodepth-${iodepth}"
output_name+=".numjobs-${numjobs}"
output_name+="${extra_info:+.${extra_info}}"
output_name+=".$(timestamp)"
}

fio_function() {
local disk_config #TODO add function for this

local name
local direct
local testfile
local blocksize
local iodepth
local ioengine
local test_type
local size
local numjobs
local gtod_reduce
local mem_align=512b
local runtime
local output_name

local rwmixread

local use_pareto

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
		unset rwmixread
	;;
esac

fio_output_name
args+=(--output="${output_name}".log)
args+=(--name="${output_name}")

fio "${args[@]}"
}


make_ext4() {
fs=ext4

parted --script /dev/"${DRIVE}" mklabel gpt mkpart "" ext4 0% 100%
mkfs.ext4 -F /dev/"${DRIVE}"p1 -E lazy_itable_init=0,lazy_journal_init=0
mount -o noatime,nodiratime /dev/"${DRIVE}"p1 /mnt/"${DRIVE}"
}

delete_ext4() {
unset fs

umount /mnt/"${DRIVE}"
wipefs -af /dev/"${DRIVE}"
}

test_matrix() {
local blocksize
local iodepth
local test_type
local size
local numjobs
local direct
local use_pareto

for blocksize in "${BLOCKSIZES[@]}"; do
	for direct in 0 1; do
		
		for iodepth in "${IODEPTHS[@]}"; do
		for ioengine in "${IOENGINES[@]}"; do
		for test_type in "${TEST_TYPES[@]}"; do
		for size in "${SIZES[@]}"; do
		for numjobs in "${NUMJOBS[@]}"; do
		for runtime in "${RUNTIMES[@]}"; do
		for use_pareto in 0 1; do
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



mkdir -p "${RESULTS_DIR}"

zpool_destroy
delete_ext4

zpool_create 9 "${ZPOOL_NAME}" "${DRIVE}"












#disk_config=8HDDdiskRAID0.64K-Strip
#disk_config=8HDDdiskZFS0
disk_config=8HDDdiskRAID0.64K-Strip.ext4

testfile=/mnt/sde/testfile
#testfile=/testdrive/64k/testfile

bs=64k
iodepth=1
numjobs=512
ioengine=libaio
direct=0
test_type=randrw
rwmixread=80

name="${test_type}"

#extra_info="size-50G"
extra_info="size-50G.pareto-.8"

#extra_info="cache-all.checksum-on"
#extra_info="pdcache-on.wt.nora.cache-off"
extra_info="pdcache-off.wb.ra.cache-on"

output_name="${RESULTS_DIR}"
output_name+="${disk_config}"
output_name+=".${test_type}"
output_name+="${rwmixread:+.rwmixread-${rwmixread}}"
output_name+=".${ioengine}"
output_name+=".bs-${bs}.iodepth-${iodepth}"
output_name+=".numjobs-${numjobs}"
output_name+=".direct-${direct}"
output_name+="${extra_info:+.${extra_info}}"
output_name+=".$(timestamp).txt"


fio \
--name="${name}" \
--filename="${testfile}" \
--bs="${bs}" \
--iodepth="${iodepth}" \
--ioengine="${ioengine}" \
--rw="${test_type}" \
--rwmixread="${rwmixread}" \
--size=50G \
--numjobs="${numjobs}" \
--gtod_reduce=1 \
--time_based \
--mem_align=512b \
--group_reporting \
--end_fsync=1 \
--direct="${direct}" \
--output-format=normal,json \
--output="${output_name}" \
--runtime=600 \
--norandommap=1 \
--random_distribution=pareto:0.8






zfs_resolve_direct() {
local direct
local checksum
local primarycache

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

zfs_resolve_logbias() {
local blocksize
local test_blocksize
local blocksize_demarcation
local test_blocksize_demarcation


test_blocksize=$(numfmt --from=iec "${blocksize}")

if [[ "${test_blocksize}" in
	
esac
}






check_fs() {
case "${fs}" in
	zfs)
		zfs_clear_testpool
		zfs_create_dataset \
			"${blocksize}" \
			"${checksum}" \
			"${logbias}" \
			"${compression}" \
			"${primarycache}" 
	;;	
esac
}











































