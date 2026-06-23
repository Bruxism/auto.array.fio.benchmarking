#!/bin/bash


#######################################
##########     Profiles      ##########
#######################################

fio_profile_bandwidth() {
blocksizes=(8k 16k 64k 128k 1MB)
iodepths_numjobs=(1,256)
ioengines=(io_uring)
test_types=(read)
directs=(0)
use_paretos=(1)
}