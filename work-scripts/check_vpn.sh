#!/bin/bash    
#description    : check vpn   
#author         :darkhex
#version        :0.1
#usage          :./check_vpn.sh
#notes          : Debian      
#============================================================================
ProcName="openvpn" 
PingHost="8.8.8.8" 
Check=`pidof $ProcName` 

StartVPN()
{
	/etc/init.d/openvpn start 
	mail -s "Start openvpn " "$email" << EOF
    Server: $server$
    Hostname: $host
	===================================================
	`tail -n 10 /var/log/openvpn.log`
	===================================================
EOF
}

RestartVPN()
{
	/etc/init.d/openvpn restart 
	mail -s "Start openvpn" "$email" << EOF
    Server: $server$
    Hostname: $host
	===================================================
	`tail -n 10 /var/log/openvpn.log`
	===================================================
EOF
}

if [ "$Check" = "" ]
then
	StartVPN
else
	#ping vpn host
	count=$(ping -c 1 $PingHost | grep 'received' | awk -F',' '{ print $2 }' | awk '{ print $1 }')
	if ! [ $count -eq 1 ]
	then
		RestartVPN
	fi
fi