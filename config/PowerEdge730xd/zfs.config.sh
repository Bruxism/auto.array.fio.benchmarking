#!/bin/bash

#######################################
########	 ZFS Config 	###########
#######################################

zfs_config_declare() {
local drive zfs_all_drives_used_temp
local sda="/dev/disk/by-id/wwn-0x5000cca04daec0b8"
local sdb="/dev/disk/by-id/wwn-0x5000cca04db0abb8"
local sdc="/dev/disk/by-id/wwn-0x5000cca04db11a94"
local sdd="/dev/disk/by-id/wwn-0x5000cca04dac6d70"
local sde="/dev/disk/by-id/wwn-0x5000cca072832eb8"
local sdf="/dev/disk/by-id/wwn-0x5000cca0729a8b00"
local sdg="/dev/disk/by-id/wwn-0x5000cca072837b80"
local sdh="/dev/disk/by-id/wwn-0x5000cca07281c3c8"
local sdi="/dev/disk/by-id/wwn-0x5000cca072844934"
local sdj="/dev/disk/by-id/wwn-0x5000cca0728495a8"
local sdk="/dev/disk/by-id/wwn-0x5000cca07283e2bc"
local sdl="/dev/disk/by-id/wwn-0x5000cca072836aa8"
local sdm="/dev/disk/by-id/wwn-0x5000c5006259e7db"
declare -ag zfs_all_drives_used

zfs_all_drives_used_temp="$(
	first=true
	for drive in $(compgen -A variable sd); do
		if "$first"; then
			printf '%s' ${!drive}
			first=false
		else
			printf ' %s' ${!drive}
		fi
	done
	)"
echo "${zfs_all_drives_used@Q}"

read -ra zfs_all_drives_used <<<  "${zfs_all_drives_used_temp}"
echo "${zfs_all_drives_used@Q}"
declare -Ag ZPOOL_LAYOUTS=(
		[SSD_4STRIPE]="12 $sda $sdb $sdc $sdd"
		[SSD_2X2RAID10]="12 mirror $sda $sdb mirror $sdc $sdd"
		[SSD_4RAIDZ1]="12 raidz1 $sda $sdb $sdc $sdd"
		[HDD_8STRIPE]="9 $sde $sdf $sdg $sdh $sdi $sdj $sdk $sdl"
		[HDD_2X4RAID10]="9 mirror $sde $sdf mirror $sdg $sdh mirror $sdi $sdj mirror $sdk $sdl"
		[HDD_2MIRROR]="9 $sde $sdf"
		[HDD_8RAIDZ2]="9 raidz2 $sde $sdf $sdg $sdh $sdi $sdj $sdk $sdl"
)
}
zfs_config_declare
declare -p zfs_all_drives_used