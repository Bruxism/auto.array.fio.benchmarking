#!/bin/bash
declare -A RAW_LAYOUTS
#######################################
############  RAW Config  #############
#######################################

# `RAW_LAYOUTS` must exist
# They keys can be whatever you want as they're
#     only used for naming the results files
# Their paired values are the paths to their drives, ideally,
#     using an absolute by-id path

RAW_LAYOUTS=(
	[SSD]="/dev/disk/by-id/wwn-0x5000cca04daec0b8"
	[HDD]="/dev/disk/by-id/wwn-0x5000cca072836aa8"
	[DellHDD]="/dev/disk/by-id/wwn-0x5000c5006259e7db"
)