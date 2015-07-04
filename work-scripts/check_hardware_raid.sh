#!/bin/bash -   
#description    :check hardware RAID
#author         :darkhex
#version        :0.1
#usage          :./check_hardware_raid.sh
#notes          : 
#Links          : 
#============================================================================

RAID_OK=`arcconf getconfig 1 ld | egrep "Status of logical device" | awk '{print $6}' | grep Optimal`
RAID_FAULT=`arcconf getconfig 1 ld | egrep "Status of logical device" | awk '{print $6}' | grep Degraded`
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
	`arcconf getconfig 1 pd|egrep "Device #|State\>|Reported Location|Reported Channel"`
	===================================================
EOF
}


if [ $RAID_FAULT ]; then
STATUS="Checked $RAID_DEVICES arrays, $RAID_STATUS have resync"
mdadmstatistics
EXIT=0
elif [ $RAID_OK ]; then
echo "All ok"
EXIT=0
else
mdadmstatistics
EXIT=0
fi

