#!/bin/bash

# fio test suite

set -euo pipefail
shopt -s globstar nullglob



# Drives to be tested
DRIVES_RAW=(/dev/sd[a-m])

# Check script location 
## This directory will be used in reference to the fio test files
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

# Initialize block device test file locations
BLOCK_DEVICE_TESTS=(${SCRIPT_DIR}/BlockTests/**/*.fio)

# Set results directory by time
RESULTS_DIR="fio.results-$(date +%Y.%m.%d-%H.%M-UTC)"

# Function for listing drive information and saving it
list_drives () {
local filename="${RESULTS_DIR}/drive_info.txt"

	{
	echo "lsblk -o PATH,SIZE,MODEL,SERIAL,WWN"
	echo ""
	lsblk -d -o PATH,SIZE,MODEL,SERIAL,WWN "${DRIVES_RAW[@]}"
	} | tee "${filename}"
}

# Function for running fio tests
# `--output` is used for the output log file
## It doesn't appear to have a jobfile equivalent option
## It's not the same as the `filename` option for fio
##   which is for where to make the test files
fio_raw_tests () {
for drive in "${DRIVES_RAW[@]}"; do
	local serial="$(lsblk -no SERIAL $drive)"
	local drive_results_dir="${RESULTS_DIR}/${serial}"
	mkdir -p "${drive_results_dir}"
	for test in "${BLOCK_DEVICE_TESTS[@]}"; do
		local test_name="$(basename -s .fio ${test})"
		testlocation=${drive} \
		fio \
		--ramp_time=30s \
		--output="${drive_results_dir}/${test_name}.txt" --output-format=normal,json \
		${test}
	done
done
}

main () {
echo "Location of script: ${SCRIPT_DIR}"
echo "Tests initialized: ${BLOCK_DEVICE_TESTS[@]}"
mkdir "${RESULTS_DIR}"
echo "Results Directory: ${RESULTS_DIR}"
list_drives
fio_raw_tests
}

main