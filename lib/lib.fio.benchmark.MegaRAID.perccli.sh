#!/bin/bash
shopt -s expand_aliases
#set location of MegaRAID perccli
alias p='/opt/MegaRAID/perccli/perccli64'

#######################################
##### HWRAID Variable Declaration #####
#######################################

if [[ -n "${HWRAID_LAYOUTS[@]}" ]]; then
	HWRAID_LAYOUTS_ALL_SLOTS_COMBINED="$(
		declare -g hwraid_all_slots_used
		declare -A hwraid_slots_used_array

		for hwraid_array in "${HWRAID_LAYOUTS[@]}"; do
			some_slots_array=()
			some_slots="$(echo ${hwraid_array} | cut -d' ' -f2)"
			IFS=, read -r -a some_slots_array <<< "${some_slots}"
			for some_slot in "${some_slots_array[@]}"; do
				declare -A hwraid_slots_used_array["${some_slot}"]=1
			done
		done

		printf '%s\n' "${!hwraid_slots_used_array[@]}" | sort -n | paste -sd,
	)"
else
	echo "Variables HWRAID_LAYOUTS not found. Skipping declarations."
fi

#######################################
########## HWRAID Functions ###########
#######################################

hwraid_clear_virtual_disks() {
p /c0/vall delete force
}

hwraid_cleanup() {
ext4_delete
hwraid_clear_virtual_disks
p /c0/e32/s"${HWRAID_LAYOUTS_ALL_SLOTS_COMBINED}" set jbod
}

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
local results_dir="${RESULTS_DIR}/HWRAID"

mkdir -p "${results_dir}"

sleep 1

p /c0 show all > "${results_dir}"/controller_info.txt

hwraid_activate_disks
hwraid_clear_virtual_disks

p /c0/e32/sall show all > "${results_dir}"/drives_all_info.txt

for hwraid_array in "${!HWRAID_LAYOUTS[@]}"; do
	disk_config="${hwraid_array}"
	read -r raid_number hwraid_disk_slots <<<\
		"${HWRAID_LAYOUTS[${hwraid_array}]}"
	hwraid_test_matrix
done
hwraid_cleanup
}

# Ideally, this would have a variable in place of v0 (virtual disk 0),
#  so that it could be used as part of a larger automation.
hwraid_get_wwn() {
p /c0/v0 show all |
sed -n 's/SCSI NAA Id = \(.*\)/\1/p'
}

hwraid_add_virtual_disk() {
p /c0 add vd \
r"${raid_number}" \
name="${disk_config}" \
drives=32:"${hwraid_disk_slots}" \
pdcache="${pdcache}" \
"${writeback}"	\
"${readahead}" \
"${cachedirect}" \
strip="${strip:-64}"

sleep 1
p /c0/v0 show all > "${results_dir}"/"${disk_config}"."$(timestamp)".txt

testdisk_wwn_basename=wwn-0x"$(hwraid_get_wwn)"
testdisk_by_id="/dev/disk/by-id/${testdisk_wwn_basename}"
}

hwraid_test_matrix() {
local iodepth_numjob

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
			for iodepth_numjob in "${iodepths_numjobs[@]}"; do
				IFS="," read -r iodepth numjobs <<< "$(echo "${iodepth_numjob}")"
				for ioengine in "${ioengines[@]}"; do
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