#!/bin/bash
declare -A ZFS_DEVICES
declare -A ZFS_ZPOOL_LAYOUTS
#######################################
############# ZFS Config ##############
#######################################

# Device name to absolute WWN path
#	Device name doesn't have to match actual path
#	This is mostly for convenience
# This is used to convert names in ZFS_ZPOOL_LAYOUTS and
#	for wiping drives
ZFS_DEVICES=(
	[sda]="/dev/disk/by-id/nvme-eui.e8238fa6bf530001001b448b4ebdf8cc"
)

ZFS_ZPOOL_LAYOUTS=(
	[SSD_1STRIPE]="9 sda"
)