#!/bin/bash    
#description    : check nginx_status    
#author         :darkhex
#version        :0.1
#usage          :./ngninx.sh
#notes          :       
#============================================================================
ProcName="nginx"
Check=`pidof $ProcName`
email="your@gmail.com"
server=`ip a | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | grep -v 127.0.0.1 | sort -u`
host=`hostname`

StatusNginx()
{
 	mail -s "Status nginx " "$email" << EOF
    Server: $server$
    Hostname: $host
	===================================================
	`systemctl status nginx.service`
	===================================================
EOF
}

StartNginx()
{
	systemctl start nginx.service 
 	mail -s "Start nginx " "$email" << EOF
    Server: $server$
    Hostname: $host
	===================================================
	`systemctl status nginx.service`
	===================================================
EOF
}

if [ "$Check" = "" ]
then
	StartNginx
else
	StatusNginx
fi
