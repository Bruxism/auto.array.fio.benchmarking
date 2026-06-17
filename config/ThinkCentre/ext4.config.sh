#!/bin/bash
declare -A EXT4_LAYOUTS
#######################################
############  Ext4 Config  ############
#######################################

EXT4_LAYOUTS=(
	[NVMe]='/dev/disk/by-id/wwn-0x33333330000007d0'
)
readonly EXT4_LAYOUTS