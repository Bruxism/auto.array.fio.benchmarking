#!/bin/bash

#######################################
#######	 Profile Functions	###########
#######################################


collect_fio_profiles() {
unset fio_profiles
local profile
declare -ag fio_profiles

echo "fio profiles:"
for profile in $(compgen -A function fio_profile_); do
	echo "${profile}"
	fio_profiles+=("${profile}")
done
}

collect_blocksizes() {
unset combined_blocksizes
local blocksize
local profile
declare -Ag combined_blocksizes

collect_fio_profiles
for profile in "${fio_profiles[@]}"; do
	export -f "${profile}"
done

declare -Ag combined_blocksizes+=$(
	declare -A combined_blocksizes
	for profile in "${fio_profiles[@]}"; do
		"${profile}"
		for blocksize in "${blocksizes[@]}"; do
			combined_blocksizes["${blocksize}"]=1
		done
	done
	echo "$(declare -p combined_blocksizes | cut -d= -f2-)"
	)
	
for profile in "${fio_profile_[@]}"; do
	export -nf "${profile}"
done
}

collect_blocksizes
echo "Combined blocksizes:"
declare -p combined_blocksizes