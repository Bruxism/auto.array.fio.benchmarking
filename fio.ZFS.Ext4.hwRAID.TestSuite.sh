#!/bin/bash

# TODO
#	Add disk configuration automation
#		for hardware RAID
#		for ZFS
#		Includes naming function adaptation

ZPOOL_NAME=testdrive
RESULTS_DIR="/root/Results"

SIZES=(50G)
RUNTIMES=(300)

readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

timestamp(){ TZ='America/Chicago' date +%Y.%m.%d-%H.%M; }

#######################################
########    Load Devices     ##########
#######################################

for file in "${SCRIPT_DIR}"/config/"$1"/*; do
	source "${file}"
done

#######################################
########    Load Profiles    ##########
#######################################

for file in "${SCRIPT_DIR}"/profiles/*; do
	source "${file}"
done

#######################################
########  Function Libraries  #########
#######################################

for file in "${SCRIPT_DIR}"/lib/*; do
	source "${file}"
done
unset file

#######################################
########   fio Functions 	###########
#######################################



fio_function() {
#local disk_config #TODO add function for this
local arg
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
	--mem_align="${mem_align:=512b}"
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
		unset rwmixread # Used for fio_output_name()
	;;
esac

fio_output_name
args+=(--output="${output_name}".log)
args+=(--name="fiotest")

# for arg in "${args[@]}"; do
# 	echo "${arg}"
# done

touch "${output_name}".log
}

fio_output_name() {
unset extra_info

if [[ -n "${mem_align}" ]]; then
	extra_info+=".mem_align-${mem_align}"
fi
if [[ "${use_pareto}" == "1" ]]; then
	extra_info+=".pareto-.8"
fi

output_name="${results_dir}"
output_name+="${disk_config}"
output_name+=".bs-${blocksize}"
output_name+=".${ioengine}"
output_name+=".direct-${direct}"
output_name+=".${test_type}"
output_name+="${rwmixread:+.rwmixread-${rwmixread}}"
output_name+=".iodepth-${iodepth}"
output_name+=".numjobs-${numjobs}"
output_name+=".size-${size}"
output_name+="${extra_info:+${extra_info}}"
output_name+=".$(timestamp)"
}


#######################################
######	Disk Config Functions	#######
#######################################



mkdir -p "${RESULTS_DIR}"

#zfs_disk_matrix

hwraid_disk_matrix





















