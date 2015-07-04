#!/bin/bash    
#description    : check php-fpm  
#author         :darkhex
#version        :0.1
#usage          :./check_php.sh
#notes          :       
#============================================================================
output=/tmp/out
email="root.murashov@gmail.com"
server=`ip a | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | grep -v 127.0.0.1 | sort -u`
host=`hostname`

ps aux | grep php | grep -v grep  | awk '{print $1}' > $output

RestartPHP()
{
	systemctl restart php-fpm.service 
 	mail -s "RestartPHP-FPM " "$email" << EOF
    Server: $server$
    Hostname: $host
	===================================================
	`systemctl status php-fpm.service `
	===================================================
EOF
}

if egrep  "apache| root" $output; then
        echo "OK" > /dev/null
else
    	RestartPHP
fi