chmod +x fio.ZFS.Ext4.hwRAID.TestSuite.sh 
source fio.ZFS.Ext4.hwRAID.TestSuite.sh PE.Single pareto


disk_config=HW_SSD_2STRIPE				# Needed

size=50GB
runtime=300
test_type=randread
direct=0								# Needed
blocksize=1MB
iodepth=1
numjobs=20
ioengine=io_uring
gtod_reduce=1
# mem_align=512b
use_pareto=1

results_dir="${RESULTS_DIR}/HWRAID"
mkdir -p "${results_dir}"
hwraid_resolve_direct
read -r raid_number hwraid_disk_slots <<< "${HWRAID_LAYOUTS[${disk_config}]}"
hwraid_activate_disks
hwraid_add_virtual_disk
sleep 1
p /c0/v0 show all > "${results_dir}"/"${disk_config}".txt
testdisk_wwn_basename=wwn-0x"$(hwraid_get_wwn)"
testdisk_by_id="/dev/disk/by-id/${testdisk_wwn_basename}"
ext4_make

export S_COLORS=always
watch  -n1 iostat -y --human 1 1

alias f=fio_function

p /c0 show all > "${results_dir}"/controller_info.txt
p /c0/e32/sall show all > "${results_dir}"/drives_all_info.txt

unset mem_align

hwraid_cleanup



disk_config=ZFS_SSD_2STRIPE				# Needed

size=50GB
runtime=300
test_type=randread
direct=0								# Needed
blocksize=1MB
iodepth=1
numjobs=20
ioengine=io_uring
gtod_reduce=1
# mem_align=512b
use_pareto=1

alias f=fio_function

declare -n zpool_name=disk_config
results_dir="${RESULTS_DIR}/zfs"
mkdir -p "${results_dir}"

disk_config=ZFS_SSD_2STRIPE
declare -n zpool=disk_config

zfs_clear_test_drives

zpool_previous="${zpool}"
	read -r ashift <<<"\
$(echo ${ZFS_ZPOOL_LAYOUTS[$zpool]} | cut -d" " -f1) \
"
	read -ra zpool_layout <<<"\
$(echo ${ZFS_ZPOOL_LAYOUTS[$zpool]} | cut -d" " -f2-) \
"
	zfs_zpool_create
	read -ra zpool_layout <<<"\
		$(echo ${ZFS_ZPOOL_LAYOUTS[$zpool]} | cut -d" " -f2-) \
		"

zfs_zpool_create

zfs_resolve_direct

checksum=off

zfs_create_dataset


testfile="/${zpool_name}/${blocksize}/testfile"

declare -n output=output_name
alias r='less ${output}.log'

zfs_clear_test_drives
hwraid_activate_disks
hwraid_add_virtual_disk
testdisk_wwn_basename=wwn-0x"$(hwraid_get_wwn)"
testdisk_by_id="/dev/disk/by-id/${testdisk_wwn_basename}"
	hwraid_add_virtual_disk
	ext4_make

results_dir="${RESULTS_DIR}/HWRAID"






size=50GB
runtime=40
test_type=randread:300
direct=0
blocksize=1MB
iodepth=8
numjobs=1
ioengine=io_uring
gtod_reduce=1
# mem_align=512b
use_pareto=0