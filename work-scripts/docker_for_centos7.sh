#!/bin/bash    
#description    :
#author         :darkhex
#version        :0.1
#usage          :./.sh
#notes          : set up docker for centos 7
#Links          : 
#============================================================================
#disable firewalld (iptables)
systemctl stop firewalld.service
systemctl disable firewalld.service
sysctl net.ipv4.conf.all.forwarding=1
#install packages
sudo yum update -y
yum install -y tmux htop mc bridge-utils install scl-utils vim 
rpm -Uvh https://www.softwarecollections.org/en/scls/rhscl/python33/epel-7-x86_64/download/rhscl-python33-epel-7-x86_64.noarch.rpm
yum -y install python33
scl enable python33 bash
easy_install pip
pip install docker-py
#https://docker-py.readthedocs.org/en/latest/#installation
#hostnamectl status
hostnamectl set-hostname docker_test
sudo systemctl restart systemd-hostnamed
#install docker and bridge
curl -sSL https://get.docker.com/ | sh
sudo service docker start
#create a bridge for docker and pipe
sudo service docker stop
sudo ip link set dev docker0 down
sudo brctl delbr docker0
sudo iptables -t nat -F POSTROUTING
sudo brctl addbr bridge0
sudo ip addr add 192.168.2.1/24 dev bridge0
sudo ip link set dev bridge0 up
echo 'DOCKER_OPTS="-b=bridge0"' >> /etc/default/docker
sudo service docker start
sudo iptables -t nat -L -n
#disable network-manager
sudo systemctl stop NetworkManager
sudo systemctl disable NetworkManager
#install iptables
yum install iptables-services -y
systemctl enable iptables
systemctl start iptables
#install pipenetwork
sudo bash -c "curl https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework > /usr/local/bin/pipework"
chmod +x /usr/local/bin/pipework
#set up bridge
cat <<EOF >>  /etc/sysconfig/network-scripts/ifcfg-eth1 
DEVICE="eth1"
ONBOOT="yes"
NM_CONTROLLED="no"
BRIDGE=bridge0
BOOTPROTO=static
EOF
cat <<EOF >> /etc/sysconfig/network-scripts/ifcfg-bridge0
DEVICE="bridge0"
ONBOOT="yes"
TYPE=Bridge
BOOTPROTO=static
IPADDR=192.168.2.1
NETMASK=255.255.255.0
EOF
#restart network
service network restart
echo "All ok"
exit 0
