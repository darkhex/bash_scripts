#!/bin/bash
#description    :
#author         :darkhex
#version        :0.1
#usage          :./.sh
#notes          : simple extended logical volumes
#Links          :
#============================================================================

echo "Please choose disk `ls /dev/mapper/*`"
read disk_name
echo "Please choose place `df -hT`"
read disk_place
umount $disk_place
lvextend -l +100%FREE $disk_name
e2fsck -f $disk_name
resize2fs $disk_name
mount $disk_name $disk_place
echo "Now we have: `df -hT`"