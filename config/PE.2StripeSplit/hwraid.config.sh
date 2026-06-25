#!/bin/bash
declare -A HWRAID_LAYOUTS
#######################################
############ HWRAID Config ############
#######################################

# First number is RAID number, and the following list is the slots used

HWRAID_LAYOUTS=(
	[HW_SSD_2STRIPE]="0 0,2"
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