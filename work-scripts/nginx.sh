#!/bin/bash
ProcName="nginx" # указываем имя процесса openvpn
Check=`pidof $ProcName` # Команда для проверки запущен ли процесс OpenVPN
email="root.murashov@gmail.com"
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
