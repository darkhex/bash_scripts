#!/bin/bash -   
#description    :Backups mariadb
#author         :darkhex
#version        :0.1
#usage          :./backup_mariadb.sh
#notes          : backup bases for engine InnoDB 
#Links          : https://www.digitalocean.com/community/tutorials/how-to-create-hot-backups-of-mysql-databases-with-percona-xtrabackup-on-centos-7
#============================================================================
email="your@gmail.com"
server=`ip a | grep -oE "\b([0-9]{1,3}\.){3}[0-9]{1,3}\b" | grep -v 127.0.0.1 | sort -u`
host=`hostname`
user_backup="backupm"
backup_dir="/var/backup"
log="/var/log/delete_backup"


if [ "$(whoami)" != 'root' ]
then
  echo $(date): Need to be root >> /data51/smbshare1/#tuneraid.log
  exit 1
fi

echo """Выберите задачу (1/2/3/4/5):
1. Install percona
2. Create a user
3. Create a backup
4. Restore backup"""
read MENUENTRY

case $MENUENTRY in
    1)
echo 'You choising "install percona"'
install_percona 
add_system
	2) 
echo 'You choising "Create a user"'
setup_user
check_user
	3) 
echo 'You choising "Create a backup"'
create_backup
delete_old
info_backup
	4) 
echo 'You choising "Restore a backup"'
restore_backup

#install percona-xtrabackup

install_percona()
{
	sudo yum install http://www.percona.com/downloads/percona-release/redhat/0.1-3/percona-release-0.1-3.noarch.rpm
	sudo yum install percona-xtrabackup
	sudo adduser $user_backup
	sudo gpasswd -a username $user_backup
	sudo gpasswd -a $user_backup mysql
	sudo mkdir -p $backup_dir
	sudo chown -R backupm: $backup_dir

setup_user()
{
    `mysql -u root -6666666` << EOF
	CREATE USER '$user_backup'@'localhost' IDENTIFIED BY 'bkppassword';
	GRANT RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO '$user_backup'@'localhost';
	FLUSH PRIVILEGES;
	exit
	EOF
}
setup_user

check_user()
{
mysql -u root -p666666! << EOF
		echo "User exsiting"	
        select User from mysql.user;
EOF
}
echo "User in system for backup"
check_user | grep $user_backup


#daily run

add_system()
{
yum install yum-cron
echo "22 22 * * * /usr/local/bin/backup_mariadb.sh &> /home/.backup_info.log" >> /etc/crontab
sudo chown -R mysql: /var/lib/mysql
sudo find /var/lib/mysql -type d -exec chmod 770 "{}" \;
}

create_backup()
{
	innobackupex --user=backupm  --password=bkppassword /data/backups
}


info_backup()
{
 	mail -s "Information about backup of $server" "$email" << EOF
    Server: $server$
    Hostname: $host
	===================================================
	`cat /home/.backup_info.log`
	===================================================
EOF
}

restore_backup()
{   
    echo ""
    #last backup 
    read MENUENTRY
	sudo systemctl stop mariadb
	mkdir /tmp/mysql
	mv /var/lib/mysql/* /tmp/mysql/
	innobackupex --copy-back $backup_dir
	sudo chown -R mysql: /var/lib/mysql
	sudo systemctl start mariadb
}


delete_old()
{
  find ./my_dir -mtime +20 -type f -delete >> $log
}





