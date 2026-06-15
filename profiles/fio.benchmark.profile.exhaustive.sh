#!/bin/bash


#######################################
##########     Profiles      ##########
#######################################

fio_profile_bandwidth() {
blocksizes=(64k 128k 1MB)
iodepths_numjobs=(1,256 256,1 4,64 64,4)
ioengines=(libaio io_uring)
test_types=(read write)
directs=(0 1)
use_paretos=(0 1)
}

fio_profile_iops() {
blocksizes=(4kb 8k 16k)
iodepths_numjobs=(1,256 256,1 4,64 64,4)
ioengines=(libaio io_uring)
test_types=(read write randread randrw)
directs=(0 1)
use_paretos=(0 1)
}

fio_profile_latency() {
blocksizes=(4kb)
iodepths_numjobs=(1,1)
ioengines=(psync)
test_types=(randread randrw)
directs=(1)
use_paretos=(0)
}