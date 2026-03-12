#!/bin/bash

#fio test suite


set -euo pipefail

#Array variable 'DRIVES'
DRIVES=(/dev/sd[a-m])
#Variable for current date and time in custom format
DATE_TIME=$(date +%Y.%m.%d-%H:%M-UTC)

#Function for listing drive information and saving it
list_drives () {
local filename="drive_info-$DATE_TIME.txt"
echo "lsblk -o PATH,SIZE,MODEL,SERIAL,WWN" > $filename
lsblk -o PATH,SIZE,MODEL,SERIAL,WWN ${drives[@]} | tee -a $filename
}

#Function for running fio tests
#`--output` is used for the output log file
##It doesn't appear to have a jobfile equivalent option
##It's not the same as the `filename` option for fio which is for where to make the test files
fio_tests () {
for drive in DRIVES; do

done
}