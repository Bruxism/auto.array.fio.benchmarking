#!/bin/bash
declare -A EXT4_LAYOUTS
#######################################
############  Ext4 Config  ############
#######################################

# `EXT4_LAYOUTS` must exist
# The keys are arbitrary and only used for naming the results file
# Their paired values are the paths to their drives, ideally,
#     using an absolute by-id path

EXT4_LAYOUTS=(
	[SSD]="/dev/disk/by-id/wwn-0x5000cca04daec0b8"
	[HDD]="/dev/disk/by-id/wwn-0x5000cca072836aa8"
	[DellHDD]="/dev/disk/by-id/wwn-0x5000c5006259e7db"
)