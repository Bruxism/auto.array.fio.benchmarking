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
	[sda]="/dev/disk/by-id/wwn-0x5000cca04daec0b8"
	[sdb]="/dev/disk/by-id/wwn-0x5000cca04db0abb8"
	[sdc]="/dev/disk/by-id/wwn-0x5000cca04db11a94"
	[sdd]="/dev/disk/by-id/wwn-0x5000cca04dac6d70"
	[sde]="/dev/disk/by-id/wwn-0x5000cca072832eb8"
	[sdf]="/dev/disk/by-id/wwn-0x5000cca0729a8b00"
	[sdg]="/dev/disk/by-id/wwn-0x5000cca072837b80"
	[sdh]="/dev/disk/by-id/wwn-0x5000cca07281c3c8"
	[sdi]="/dev/disk/by-id/wwn-0x5000cca072844934"
	[sdj]="/dev/disk/by-id/wwn-0x5000cca0728495a8"
	[sdk]="/dev/disk/by-id/wwn-0x5000cca07283e2bc"
	[sdl]="/dev/disk/by-id/wwn-0x5000cca072836aa8"
	[sdm]="/dev/disk/by-id/wwn-0x5000c5006259e7db"
)

ZFS_ZPOOL_LAYOUTS=(
	[ZFS_SSD_2STRIPE]="12 sdc sdd"
)