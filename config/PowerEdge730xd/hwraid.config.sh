#!/bin/bash
declare -A HWRAID_LAYOUTS
#######################################
############ HWRAID Config ############
#######################################

# First number is RAID number, and the following list is the slots used

HWRAID_LAYOUTS=(
	[HDD_8STRIPE]="0 9,11,13,15,17,19,21,23"
	[HDD_1STRIPE]="0 15"
	[HDD_6STRIPE]="0 13,15,17,19,21,23"
	[HDD_4x2RAID10]="10 9,11,13,15,17,19,21,23"
	[HDD_1x2MIRROR]="1 9,11"
	[HDD_8RAID6]="6 9,11,13,15,17,19,21,23"
	[SSD_4STRIPE]="0 0,2,4,7"
	[SSD_3STRIPE]="0 0,2,4,7"
	[SSD_1STRIPE]="0 4"
	[SSD_2x2RAID10]="10 0,2,4,7"
	[SSD_4RAID5]="5 0,2,4,7"
 )
 readonly HWRAID_LAYOUTS

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
readonly HWRAID_LAYOUTS_ALL_SLOTS_COMBINED