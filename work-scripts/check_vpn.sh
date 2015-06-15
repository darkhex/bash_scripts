#!/bin/bash
ProcName="nginx" # указываем имя процесса openvpn
PingHost="10.10.0.1" # указываем хост, который доступен только если поднят OpenVPN канал
Check=`pidof $ProcName` # Команда для проверки запущен ли процесс OpenVPN
email="root.murashov@gmail.com"
server=`ip a | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | grep -v 127.0.0.1 | sort -u`


StatusNginx()
{
	systemctl status nginx.service | grep active | awk '{print $2}' 
}

StartNginx()
{
	systemctl start nginx.service # Стартуем процесс
}

RestartNginx()
{
	systemctl restart nginx.service # Рестартим процесс
}

if [ "$Check" = "" ]
then
	# Если процесс не запущен, то стартуем VPN
	StartNginx
else
	# Если процесс запущен, то проверяем, доступен ли сервер VPN, если нет, рестартим.
	StatusNginx
    if [ $? -eq inactive ]; then
		RestartNginx
		 mail -s "Status nginx after trouble" "$email" << EOF
		 $server
	    ===================================================

	    `systemctl status nginx.service`

	    ===================================================
EOF
	fi
fi