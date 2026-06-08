#!/bin/bash
declare -A HWRAID_LAYOUTS
#######################################
############ HWRAID Config ############
#######################################

# First section is RAID number, and the following list is the slots used

HWRAID_LAYOUTS=(
	[HDD8diskRAID0]="0 9,11,13,15,17,19,21,23"
	[SSD4diskRAID0]="0 0,2,4,7"
 )