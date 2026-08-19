source disk_list.sh

drive=sde
mkdir -p /root/Results


zfs create -o logbias=throughput -o checksum=off -o compression=lz4 -o primarycache=none -o volblocksize=1M -V 1T testdrive/testvol1M




zpool create -o ashift=9 -o autotrim=off testdrive /dev/${drive}

zfs create -o atime=off -o logbias=throughput -o checksum=off -o compression=lz4 -o primarycache=metadata -o xattr=sa -o recordsize=4k testdrive/4k



RESULTS_DIR="/root/Results/"

mkdir -p "${RESULTS_DIR}"

timestamp(){ TZ='America/Chicago' date +%Y.%m.%d-%H.%M; }

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

#DISK_HDD_SLOTS found in disk_list.sh
##It's my personal list of drives by RAID slot number
p /c0/e32/s"${DISK_HDD_SLOTS}" set good force

#p /c0 add vd r0 name=8diskRAID0 drives=32:"${DISK_HDD_SLOTS}" pdcache=on wt nora direct

p /c0 add vd r0 name=8diskRAID0 drives=32:"${DISK_HDD_SLOTS}" pdcache=off wb ra cached

umount /dev/"${drive}"
p /c0/v0 delete 

p /c0/e32/s"${DISK_HDD_SLOTS}" set jbod

#WWN_HDD_8DISK found in disk_list.sh
##It's my personal list of drives by WWN id
unset wwn8disk
declare -a wwn8disk
for wwn in "${WWN_HDD_8DISK[@]}"; do
	wwn8disk+=("/dev/disk/by-id/wwn-${wwn}")
done


zpool import -a
zpool destroy testdrive
wipefs -af ${wwn8disk[*]}
echo "sleep 1" && sleep 1
zpool create -o ashift=9 -o autotrim=off -O relatime=on testdrive ${wwn8disk[*]}
zfs create -o relatime=on -o logbias=throughput -o checksum=on -o compression=lz4 -o primarycache=all -o xattr=sa -o recordsize=64k testdrive/64k

zpool destroy testdrive
wipefs -af ${wwn8disk[*]}









