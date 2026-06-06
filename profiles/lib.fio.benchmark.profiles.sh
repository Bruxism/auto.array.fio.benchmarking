#!/bin/bash


#######################################
########	Profiles	###############
#######################################

fio_profile_bandwidth() {
blocksizes=(8kb 16kb 1MB)
numjobss=(1 2 4 64 128 256)
iodepths=(1 2 4 64 128 256)
ioengines=(libaio io_uring)
test_types=(read write)
directs=(0 1)
use_paretos=(0 1)
}

fio_profile_iops() {
blocksizes=(4kb 8kb 16kb)
numjobss=(1 2 4 64 128 256)
iodepths=(1 2 4 64 128 256)
ioengines=(libaio io_uring)
test_types=(read write randread randrw)
directs=(0 1)
use_paretos=(0 1)
}

fio_profile_latency() {
blocksizes=(4kb)
numjobss=(1)
iodepths=(1)
ioengines=(psync)
test_types=(randread randrw)
directs=(1)
use_paretos=(0)
}