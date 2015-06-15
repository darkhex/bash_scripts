#!/bin/bash    
#description    : check nginx_status    
#author         :darkhex
#version        :0.1
#usage          :./ngninx.sh
#notes          :       
#============================================================================
email="root.murashov@gmail.com"
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

#xl top | tr '\r' '\n' | sed 's/[0-9][;][0-9][0-9][a-Z]/ /g' | col -bx | sed 1,4d | awk '{print $2,$5,$6}'

xm list | awk '{print $5}' | grep -v State

if grep -q r,b 
	then echo "All ok" > /dev/null
else
   Failxen
fi


