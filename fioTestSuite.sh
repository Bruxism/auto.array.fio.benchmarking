#!/bin/bash

# fio test suite

set -euo pipefail
shopt -s globstar nullglob

# Check script location 
## This directory will be used in reference to the fio test files
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
echo "Location of script: $SCRIPT_DIR"

# Array variable 'DRIVES'
DRIVES=(/dev/sd[a-m])
echo "Drive array initialized: ${DRIVES[@]}"

# Initialize block device test file locations
BLOCK_DEVICE_TESTS=($SCRIPT_DIR/BlockTests/**/*.fio)
echo "Tests initialized: ${BLOCK_DEVICE_TESTS[@]}"

# Set results directory by time
RESULTS_DIR="fio.results-$(date +%Y.%m.%d-%H:%M-UTC)"
echo "Results Directory: $RESULTS_DIR"

# Function for listing drive information and saving it
list_drives () {
# Variable for current date and time in custom format
local filename="$RESULTS_DIR/drive_info.txt"
echo "lsblk -o PATH,SIZE,MODEL,SERIAL,WWN" | tee $filename
echo "" | tee -a $filename
lsblk -o PATH,SIZE,MODEL,SERIAL,WWN ${DRIVES[@]} | tee -a $filename
}

# Function for running fio tests
# `--output` is used for the output log file
## It doesn't appear to have a jobfile equivalent option
## It's not the same as the `filename` option for fio
##   which is for where to make the test files
fio_tests () {
for drive in "${DRIVES[@]}"; do
	local serial="$(lsblk -no SERIAL $drive)"
	local drive_results_dir="$RESULTS_DIR/$serial"
	mkdir -p "$drive_results_dir"
	for test in "${BLOCK_DEVICE_TESTS[@]}"; do
		local test_name="$(basename -s .fio $test)"
		testlocation=$drive \
		fio \
		--ramp_time=30s \
		--output="$drive_results_dir/$test_name.txt" --output-format=normal \
		--output="$drive_results_dir/$test_name.json" --output-format=json \
		$test
	done
done
}

main () {
mkdir $RESULTS_DIR
list_drives
fio_tests
}

main