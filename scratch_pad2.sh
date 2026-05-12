#!/bin/bash

DRIVE=nvme0n1
ZPOOL_NAME=testdrive
RESULTS_DIR="/root/Results/"


timestamp() {
TZ='America/Chicago' \
date +%Y.%m.%d-%H.%M;
}

zpool_destroy() {
local drive="$1"
local zpool_name="$2"

zpool import -a
zpool destroy "${zpool_name}"
wipefs -af /dev/"${drive}"
blkdiscard -f /dev/"${drive}"
}

zpool_create() {
local ashift="$1"
local zpool_name="$2"
local drive="$3"

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
local logbias="$3"
local compression="$4"
local primarycache="$5"
local zpool_name="$6"

zfs create \
-o recordsize="${recordsize}" \
-o checksum="${checksum}" \
-o logbias="${logbias}" \
-o checksum="${checksum}" \
-o compression="${compression}" \
-o primarycache="${primarycache}" \
-o xattr=sa \
-o atime=off \
"${zpool_name}"/"${blocksize}"
}

fio_function() {
local name
local testfile
local blocksize
local iodepth
local ioengine
local test_type
local 
local
local



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
}





















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




mkdir -p "${RESULTS_DIR}"