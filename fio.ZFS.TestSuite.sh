#!/bin/bash

# fio ZFS test suite

set -euo pipefail 
# `|| true` added on certain commands to prevent exit on intended failure
shopt -s globstar nullglob

##############################################
##			USER CONFIGURATION				##
##############################################

# zpool layout definitions
# Each value will be passed after `zpool create (options)`
# Use a descriptive [key] as it'll be used for its results folder name
# Example:
# 	declare -A ZPOOL_LAYOUTS=(
# 		[SSD_4RAID10]="mirror sda sdb mirror sdc sdd"
#		[SSD_4STRIPE]="sda sdb sdc sdd"
#		[HDD_8STRIPE]="sde sdf sdg sdh sdi sdj sdk sdl"
# 	)

declare -A ZPOOL_LAYOUTS=(
		[SSD_4STRIPE]="sda sdb sdc sdd"
 		[SSD_2X2RAID10]="mirror sda sdb mirror sdc sdd"
		[SSD_4RAIDZ1]="raidz1 sda sdb sdc sdd"
		[HDD_8STRIPE]="sde sdf sdg sdh sdi sdj sdk sdl"
		[HDD_2X4RAID10]="mirror sde sdf mirror sdg sdh mirror sdi sdj mirror sdk sdl"
		[HDD_2MIRROR]="sde sdf"
		[HDD_8RAIDZ2]="raidz2 sde sdf sdg sdh sdi sdj sdk sdl"
)


##############################################
##	 	END USER CONFIGURATION				##
##############################################

##############################################
##				VARIABLES					##
##############################################

# Check script location 
## This directory will be used in reference to the fio test files
readonly SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

# Drives read from ZPOOL_LAYOUTS will be collected here
declare -a DRIVES=()

# Initialize fio test file locations
FIO_TESTS=("${SCRIPT_DIR}"/BlockTests/**/*.fio)

# Initialize array for 4k and 1M based tests
FIO_TESTS_4k=()
FIO_TESTS_1M=()

# Set results directory by time
readonly BASE_RESULTS_DIR="fio.results-$(date +%Y.%m.%d-%H.%M-UTC)"

##############################################
##				END VARIABLES				##
##############################################

##############################################
##				FUNCTIONS					##
##############################################

# Split fio test files between 4k and 1M tests
categorize_tests() {
local test

FIO_TESTS_4k=()
FIO_TESTS_1M=()

for test in "${FIO_TESTS[@]}"; do
	case "$test" in
		*latency*|*IOPS*)
		FIO_TESTS_4k+=("${test}")
		;;
		*throughput*)
		FIO_TESTS_1M+=("${test}")
		;;
		*)
		exit 1
		;;
	esac
done
echo "Initialized 4k tests: ${FIO_TESTS_4k[*]}"
echo "Initialized 1M tests: ${FIO_TESTS_1M[*]}"
}

# List and save drive info
list_drives() {
local filename="${BASE_RESULTS_DIR}"/drive_info.txt

	{
	echo "lsblk -d -o PATH,SIZE,MODEL,SERIAL,WWN"
	echo ""
	lsblk -d -o PATH,SIZE,MODEL,SERIAL,WWN ${DRIVES[@]}
	} | tee "${filename}"
}

# The following two functions 
#   are for collecting unique drive names
## It prepares array variable DRIVES to be used to prepare
##   and wipe the drives at the start of and between tests
is_zfs_keyword() {
case "$1" in
	mirror|raidz*|draid*|spare|log|dedup|special|cache)
	return 0
	;;
esac
return 1
}

collect_unique_drives() {
local layouts
local word
local -A unique_drives
local drive

for layouts in "${ZPOOL_LAYOUTS[@]}"; do
	for word in ${layouts}; do
		if ! is_zfs_keyword "$word"; then
			unique_drives["${word}"]=1
		fi
	done
done
for drive in $(sort <(printf "%s\n" "${!unique_drives[@]}")); do
	DRIVES+=("/dev/${drive}")
done
}


# Unmount/Export any zpool and wipe any filesystem
clear_zfs_fs() {
zpool export -a || true
wipefs -af "${DRIVES[@]}"
echo "All zpool exported and filesystem wiped from script-configured drives"
}

# TRIM or UNMAP SSD
## `OR true` so that it doesn't fail out from the `set -euo pipefail`
block_discard() {
local drive

for drive in "${DRIVES[@]}"; do
	blkdiscard --force "${drive}" || true
done
}

# Create zpools and their 4k and 1M recordsize datasets
create_zpool_plus_datasets() {
local zpool_name="$1"
local zpool_layout="$2"

echo "Creating zpool: ${zpool_name} ${zpool_layout}"
zpool create -o ashift=12 -o autotrim=on ${zpool_name} ${zpool_layout}
echo "Creating dataset ""${zpool_name}""/4k"
zfs create -o atime=off -o compression=lz4 -o xattr=sa -o recordsize=4k "${zpool_name}"/4k
echo "Creating dataset ""${zpool_name}""/1M"
zfs create -o atime=off -o compression=lz4 -o xattr=sa -o recordsize=1M "${zpool_name}"/1M
}

# List and save ZFS info
list_zfs() {
local zpool_results_dir="$1"
local filename="${zpool_results_dir}/zfs_info.txt"

	{
	echo "zpool get all"
	echo
	zpool get all
	echo
	echo "zfs get all"
	echo
	zfs get all
	} | tee "${filename}"
}

# Function logic for running fio tests
# `--output` is used for the output log file
## It doesn't appear to have a jobfile equivalent option
## It's not the same as the `filename` option for fio
##   which is for where to make the test files
fio_zfs_tests() {
local zpool_name="$1"
local zpool_results_dir="$2"

local test
local test_name
local testlocation
local ioengines=("io_uring" "libaio")

for ioengine in "${ioengines[@]}"; do
	for test in "${FIO_TESTS_4k[@]}"; do
		testlocation=/"${zpool_name}"/4k/testfile \
		fio_test
	done
	for test in "${FIO_TESTS_1M[@]}"; do
		testlocation=/"${zpool_name}"/1M/testfile \
		fio_test
	done
done
}

echo_tests() {
	echo "Running test with:"
	echo -e "\tPool: ${zpool_name}"
	echo -e "\tLayout ${zpool_layout}"
	echo -e "\tEngine: ${ioengine}"
}

fio_test() {
	echo_tests
	test_name="$(basename -s .fio ${test})"
	
	fio \
		--ioengine="${ioengine}" \
		--size=20GB \
		--output="${zpool_results_dir}/${test_name}-${ioengine}.txt" \
		--output-format=normal,json \
		"${test}"
}

##############################################
##				END FUNCTIONS				##
##############################################

mkdir -p "${BASE_RESULTS_DIR}"

collect_unique_drives
echo "Drive array initialized: ${DRIVES[@]}"
echo "Location of script: ${SCRIPT_DIR}"
echo "Tests initialized: ${FIO_TESTS[@]}"
echo "Results Directory: ${BASE_RESULTS_DIR}"

list_drives
categorize_tests

for zpool in "${!ZPOOL_LAYOUTS[@]}"; do
	zpool_name="${zpool,,}"
	zpool_layout="${ZPOOL_LAYOUTS[${zpool}]}"
	echo "zpool name: ${zpool_name}"
	echo "zpool layout: ${zpool_layout}"
	clear_zfs_fs
	block_discard
	zpool_results_dir="${BASE_RESULTS_DIR}"/"${zpool_name}"
	mkdir -p "${zpool_results_dir}"
	create_zpool_plus_datasets "${zpool_name}" "${zpool_layout}"
	list_zfs "${zpool_results_dir}"
	fio_zfs_tests "${zpool_name}" "${zpool_results_dir}"
done





#TODO
#Add cache-wipe between runs
#Add a variable or function for checking how much free RAM there is and
#	scale how much the test amount is to account for a realistic amount
#	of cache hits (~80% cache hits so size is ~120% of free RAM)
#	Or use random_distribution=
#Add specification of mix 80/20 read/write
#	rwmixread=
#
#
#



