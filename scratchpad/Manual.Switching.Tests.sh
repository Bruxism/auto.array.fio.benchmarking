# Make sure to source in both HWRAID and ZFS because the script wipes the HWRAID--then continue the setup

chmod +x fio.ZFS.Ext4.hwRAID.TestSuite.sh
source fio.ZFS.Ext4.hwRAID.TestSuite.sh PE.2StripeSplit pareto
alias f=fio_function
declare -n output=output_name
alias r='less ${output}.log'



disk_config=HW_SSD_2STRIPE				# Needed

size=50GB
runtime=300
test_type=randread
direct=1								# Needed
blocksize=1MB
iodepth=1
numjobs=20
ioengine=io_uring
gtod_reduce=1
# mem_align=512b
use_pareto=1

results_dir="${RESULTS_DIR}/HWRAID"
mkdir -p "${results_dir}"
hwraid_cleanup
hwraid_resolve_direct
read -r raid_number hwraid_disk_slots <<< "${HWRAID_LAYOUTS[${disk_config}]}"
hwraid_activate_disks
hwraid_add_virtual_disk
sleep 1
p /c0/v0 show all > "${results_dir}"/"${disk_config}".txt
testdisk_wwn_basename=wwn-0x"$(hwraid_get_wwn)"
testdisk_by_id="/dev/disk/by-id/${testdisk_wwn_basename}"
ext4_make # Already includes testfile

p /c0 show all > "${results_dir}"/controller_info.txt
p /c0/e32/sall show all > "${results_dir}"/drives_all_info.txt

unset mem_align

alias f=fio_function

#testfile="${test_mountdir}/"	# for use with --directory






export S_COLORS=always
watch  -n1 iostat -y --human 1 1



wipefs -af

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

#checksum=off
zfs_clear_testpool_datasets
zfs_create_dataset
testfile="/${zpool_name}/${blocksize}/testfile"
#testfile="/${zpool_name}/${blocksize}/"


zfs_clear_test_drives
hwraid_activate_disks
hwraid_add_virtual_disk
testdisk_wwn_basename=wwn-0x"$(hwraid_get_wwn)"
testdisk_by_id="/dev/disk/by-id/${testdisk_wwn_basename}"
	hwraid_add_virtual_disk
	ext4_make

results_dir="${RESULTS_DIR}/HWRAID"


results_dir="${RESULTS_DIR}/zvol"
mkdir -p "${results_dir}"










disk_config=ZFS_SSD_2STRIPE_ZVOL"${blocksize}"


size=50GB
runtime=120
test_type=randwrite
direct=0
blocksize=8MB
iodepth=8
numjobs=4
ioengine=io_uring
gtod_reduce=0
# mem_align=512b
use_pareto=1





# For fio_function_distributed
size=4k-32MB
runtime=180
test_type=readwrite
direct=0
blocksize=128k
iodepth=64
numjobs=1
ioengine=io_uring
gtod_reduce=0
# mem_align=512b
use_pareto=0