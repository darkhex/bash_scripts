#!/bin/bash -   
#description    :check mdadm
#author         :darkhex
#version        :0.1
#usage          :./check_mdadm.sh
#notes          : check_mdadm
#Links          : https://exchange.nagios.org/directory/Plugins/Operating-Systems/Linux/check_md_raid/details
#============================================================================
RAID_DEVICES=`grep ^md -c /proc/mdstat`
RAID_RECOVER=`mdadm --detail /dev/md1 | grep State | grep recover | awk '{print $4}' | head -1`
RAID_RESYNC=`mdadm --detail /dev/md1 | grep State | grep resync | awk '{print $4}' | head -1`
RAID_OK=` mdadm --detail /dev/md1 | grep State | grep active  | awk '{print $4}' | head -1`
RAID_FAULT=` mdadm --detail /dev/md1 | grep State | grep degraded  | awk '{print $4}' | head -1`
email=root.murashov@gmail.com
server=`ip a | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | grep -v 127.0.0.1 | sort -u`
host=`hostname`

if [ "$(whoami)" != 'root' ]
then
  echo $(date): Need to be root >> /tmp/false
  exit 1
fi


mdadmstatistics()
{
 	mail -s "RAID IN DANGEROUS" "$email" << EOF
    Server: $server$
    Hostname: $host
	===================================================
	`mdadm --detail /dev/md1`
	===================================================
EOF
}


if [ $RAID_RECOVER ]; then
mdadmstatistics
EXIT=0
elif [ $RAID_RESYNC ]; then
mdadmstatistics
EXIT=0
# RAID ok
elif [ $RAID_OK ]; then
echo "All ok"
EXIT=0
elif [ $RAID_FAULT ]; then
mdadmstatistics
EXIT=0
else
mdadmstatistics
EXIT=0
fi



