#!/bin/bash
shopt -s expand_aliases
#set location of MegaRAID perccli
alias p='/opt/MegaRAID/perccli/perccli64'

hwraid_activate_disks() {
p /c0/e32/s"${HWRAID_LAYOUTS_ALL_SLOTS_COMBINED}" set good force
}

hwraid_resolve_direct() {
case "${direct}" in
	1)
		pdcache=on
		writeback=wt
		readahead=nora
		cachedirect=direct
	;;
	0)
		pdcache=off
		writeback=wb
		readahead=ra
		cachedirect=cached
	;;
esac
}

hwraid_disk_matrix() {
local testdisk_wwn_basename
local testdisk_by_id
local test_partition
local test_mountdir
local testfile
local disk_config
local hwraid_array raid_number hwraid_disk_slots
local pdcache writeback readahead cachedirect
local results_dir="${RESULTS_DIR}/HWRAID/"

mkdir -p "${results_dir}"

sleep 1
hwraid_activate_disks
hwraid_clear_virtual_disks
for hwraid_array in "${!HWRAID_LAYOUTS[@]}"; do
	disk_config="${hwraid_array}"
	read -r raid_number hwraid_disk_slots <<<\
		"${HWRAID_LAYOUTS[${hwraid_array}]}"
	hwraid_test_matrix
done
hwraid_cleanup
}

hwraid_add_virtual_disk() {

p /c0 add vd \
r"${raid_number}" \
name="${disk_config}" \
drives=32:"${hwraid_disk_slots}" \
pdcache="${pdcache}" \
"${writeback}"	\
"${readahead}" \
"${cachedirect}"

testdisk_wwn_basename=wwn-0x"$(hwraid_get_wwn)"
testdisk_by_id="/dev/disk/by-id/${testdisk_wwn_basename}"
}

hwraid_test_matrix() {
local iodepth_i

for direct in 1 0; do
	if [[ -n "${testdisk_wwn_basename}" ]]; then
		ext4_delete
		p /c0/v0 delete 
	fi
	hwraid_resolve_direct
	hwraid_add_virtual_disk
	ext4_make
	for profile in "${fio_profiles[@]}"; do
		"${profile}"
		# Skip psync when direct=0 since psync doesn't have direct=0
		[[ " ${directs[@]} " =~ " ${direct} " ]] || continue
		for blocksize in "${blocksizes[@]}"; do
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

hwraid_cleanup() {
ext4_delete
hwraid_clear_virtual_disks
p /c0/e32/s"${HWRAID_LAYOUTS_ALL_SLOTS_COMBINED}" set jbod
}

# Ideally, this would have a variable in place of v0,
#  so that it could be used as part of a larger
#  automation.
hwraid_get_wwn() {
p /c0/v0 show all |
sed -n 's/SCSI NAA Id = \(.*\)/\1/p'
}

hwraid_clear_virtual_disks() {
p /c0/vall delete force
}