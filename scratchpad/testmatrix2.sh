#!/bin/bash

BLOCKSIZES=(4kb 16kb 1M 32M)
IODEPTHS=(1 4 64)
NUMJOBS=(1 4 64)
TEST_TYPES=(read write randread randwrite readwrite randrw)
IOENGINES=(libaio io_uring psync)
SIZES=(50G)
RUNTIMES=(300)

test_matrix2() {
local blocksize
local iodepth
local iodepth_i
local test_type
local size
local numjobs
local direct
local use_pareto

for blocksize in "${BLOCKSIZES[@]}"; do
for direct in 0 1; do
	# Iterate through IODEPTHS and at the same time,
	# 	iterate in the reverse of NUMJOBS.
	# 	They should have the same set of numbers for simplicity.
	for ((iodepth_i=0; iodepth_i<"${#IODEPTHS[@]}"; iodepth_i++)); do
		iodepth="${IODEPTHS[iodepth_i]}"
		numjobs="${NUMJOBS[-1-iodepth_i]}"		
		for ioengine in "${IOENGINES[@]}"; do
			# If ioengine is psync, then iodepth is set to 1 by fio
			#	on the backend anyway. It also means that it's testing for
			# 	latency so it needs gtod_reduce to be off to record them.
			# This is really just for the fio_output_name function.
			# If any other test is on, then latency is probably going
			#	to be blasted by IOPS or bandwidth for measuring those, and
			#	turning it off means getting closer to maximizing performance
			#	for those metrics.
			if [[ "${ioengine}" == psync ]]; then
				if [[
					"${direct}" != 1 &&
					"${iodepth}" != 1
				]]; then
					continue
				fi
				numjobs=1
				gtod_reduce=0
			else
				gtod_reduce=1
			fi
			for test_type in "${TEST_TYPES[@]}"; do
				if [[ "${ioengine}" == psync ]]; then
					if [[
						"${direct}" != "randread" ||
						"${direct}" != "randrw"
					]]; then
						continue
					fi
				fi
				if [[ "${ioengine}" == psync ]]; then
					if [[
						"${direct}" != "randread" ||
						"${direct}" != "randrw"
					]]; then
						continue
					fi
				fi
				for size in "${SIZES[@]}"; do
				for runtime in "${RUNTIMES[@]}"; do
				for use_pareto in 0 1; do
					matrix_fs_case
					fio_function
				done
				done
				done
			done
		done
	done
done
done
}