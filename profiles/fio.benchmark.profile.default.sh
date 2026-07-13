#!/bin/bash


#######################################
##########     Profiles      ##########
#######################################

fio_profile_bandwidth_sequential () {
blocksizes=(64k 128k 1MB)
iodepths_numjobs=(20,1)
ioengines=(io_uring)
test_types=(read write)
directs=(0 1)
use_paretos=(0)
}

fio_profile_bandwidth_random () {
blocksizes=(64k 128k 1MB)
iodepths_numjobs=(20,1)
ioengines=(io_uring)
test_types=(randread randwrite randrw)
directs=(0 1)
use_paretos=(0 1)
}

fio_profile_iops_sequential () {
blocksizes=(4kb 8k 16k)
iodepths_numjobs=(20,1)
ioengines=(io_uring)
test_types=(read write)
directs=(0 1)
use_paretos=(0)
}

fio_profile_iops_random () {
blocksizes=(4kb 8k 16k)
iodepths_numjobs=(20,1)
ioengines=(io_uring)
test_types=(randread randwrite randrw)
directs=(0 1)
use_paretos=(0 1)
}

fio_profile_latency () {
blocksizes=(4kb)
iodepths_numjobs=(1,1)
ioengines=(psync)
test_types=(randread randrw)
directs=(1)
use_paretos=(0)
}