#!/bin/bash    
#description    : check nginx_status    
#author         :darkhex
#version        :0.1
#usage          :./ngninx.sh
#notes          :       
#============================================================================
email="your@gmail.com"
server=`ip a | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | grep -v 127.0.0.1 | sort -u`
host=`hostname`


Failxen()
{
 	mail -s "Fail xen on $server" "$email" << EOF
    Server: $server$
    Hostname: $host
	===================================================
	`systemctl status nginx.service`
	===================================================
EOF
}

xm list | awk '{print $5}' | grep -v State

if grep -q r,b 
	then echo "All ok" > /dev/null
else
   Failxen
fi


