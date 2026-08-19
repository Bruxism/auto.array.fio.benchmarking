#!/bin/bash
declare -A HWRAID_LAYOUTS
#######################################
############ HWRAID Config ############
#######################################

# First number is RAID number, and the following list is the slots used

HWRAID_LAYOUTS=(
	[SSD_4STRIPE]="0 0,2,4,7"
 )