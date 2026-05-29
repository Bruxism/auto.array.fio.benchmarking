#!/bin/bash

#set location of MegaRAID perccli
alias p='/opt/MegaRAID/perccli/perccli64'

#DISK_HDD_SLOTS found in disk_list.sh
##It's my personal list of drives by RAID slot number
p /c0/e32/s"${DISK_HDD_SLOTS}" set good force

#p /c0 add vd r0 name=8diskRAID0 drives=32:"${DISK_HDD_SLOTS}" pdcache=on wt nora direct

p /c0 add vd r0 name=8diskRAID0 drives=32:"${DISK_HDD_SLOTS}" pdcache=off wb ra cached

umount /dev/"${drive}"
p /c0/v0 delete 

p /c0/e32/s"${DISK_HDD_SLOTS}" set jbod

#WWN_HDD_8DISK found in disk_list.sh
##It's my personal list of drives by WWN id
unset wwn8disk
declare -a wwn8disk
for wwn in "${WWN_HDD_8DISK[@]}"; do
	wwn8disk+=("/dev/disk/by-id/wwn-${wwn}")
done