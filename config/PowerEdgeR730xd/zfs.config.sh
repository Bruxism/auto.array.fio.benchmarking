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
	[HDD_8STRIPE]="9 sde sdf sdg sdh sdi sdj sdk sdl"
	[HDD_1STRIPE]="9 sdh"
	[HDD_6STRIPE]="9 sdg sdh sdi sdj sdk sdl"
	[HDD_4x2RAID10]="9 mirror sde sdf mirror sdg sdh mirror sdi sdj mirror sdk sdl"
	[HDD_1x2MIRROR]="9 sde sdf"
	[HDD_8RAID6]="9 raidz2 sde sdf sdg sdh sdi sdj sdk sdl"
	[SSD_4STRIPE]="12 sda sdb sdc sdd"
	[SSD_3STRIPE]="12 sda sdb sdc sdd"
	[SSD_1STRIPE]="12 sdc"
	[SSD_2x2RAID10]="12 mirror sda sdb mirror sdc sdd"
	[SSD_4RAID5]="12 raidz1 sda sdb sdc sdd"
)