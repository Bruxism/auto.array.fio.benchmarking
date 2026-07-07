#!/bin/bash
declare -A HWRAID_LAYOUTS
#######################################
############ HWRAID Config ############
#######################################

# First number is RAID number, and the following list is the slots used

HWRAID_LAYOUTS=(
	[HW_SSD_2STRIPE]="0 0,2"
 )