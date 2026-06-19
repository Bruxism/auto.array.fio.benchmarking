#!/bin/bash
declare -A ZFS_ZPOOL_LAYOUTS
declare -A ZFS_DEVICES
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
readonly ZFS_DEVICES

ZFS_ZPOOL_LAYOUTS=(
	[SSD_1STRIPE]="9 sda"
)
# Change ZFS_ZPOOL_LAYOUTS device names to WWN paths
for pool in "${!ZFS_ZPOOL_LAYOUTS[@]}"; do
    new_layout=()
    for token in ${ZFS_ZPOOL_LAYOUTS["${pool}"]}; do
        new_layout+=("${ZFS_DEVICES[$token]:-$token}")
    done
    ZFS_ZPOOL_LAYOUTS["${pool}"]="${new_layout[*]}"
	unset pool new_layout token
done
readonly ZFS_ZPOOL_LAYOUTS
declare -p ZFS_ZPOOL_LAYOUTS