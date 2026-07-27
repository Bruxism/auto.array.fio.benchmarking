#!/bin/bash
declare -A HWRAID_LAYOUTS
#######################################
############ HWRAID Config ############
#######################################

# First number is RAID number, and the following list is the slots used

HWRAID_LAYOUTS=(
	[HDD_8STRIPE]="0 9,11,13,15,17,19,21,23"
	[HDD_1STRIPE]="0 15"
	[HDD_6STRIPE]="0 13,15,17,19,21,23"
	[HDD_4x2RAID10]="10 9,11,13,15,17,19,21,23"
	[HDD_1x2MIRROR]="1 9,11"
	[HDD_8RAID6]="6 9,11,13,15,17,19,21,23"
	[SSD_4STRIPE]="0 0,2,4,7"
	[SSD_3STRIPE]="0 0,2,4,7"
	[SSD_1STRIPE]="0 4"
	[SSD_2x2RAID10]="10 0,2,4,7"
	[SSD_4RAID5]="5 0,2,4,7"
 )