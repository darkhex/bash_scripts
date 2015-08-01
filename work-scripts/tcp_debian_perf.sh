#!/bin/bash

cp /etc/sysctl.conf /etc/sysctl.conf.bak

>/etc/sysctl.conf cat << EOF 

# Disable syncookies (syncookies are not RFC compliant and can use too muche resources)
net.ipv4.tcp_syncookies = 0

# Basic TCP tuning
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_synack_retries = 3
net.ipv4.tcp_syn_retries = 3

# RFC1337
net.ipv4.tcp_rfc1337 = 1

# Defines the local port range that is used by TCP and UDP
# to choose the local port
net.ipv4.ip_local_port_range = 1024 65535

# Log packets with impossible addresses to kernel log
net.ipv4.conf.all.log_martians = 1

# Minimum interval between garbage collection passes This interval is
# in effect under high memory pressure on the pool
net.ipv4.inet_peer_gc_mintime = 5

# Disable Explicit Congestion Notification in TCP
net.ipv4.tcp_ecn = 0

# Enable window scaling as defined in RFC1323
net.ipv4.tcp_window_scaling = 1

# Enable timestamps (RFC1323)
net.ipv4.tcp_timestamps = 1

# DISable select acknowledgments
net.ipv4.tcp_sack = 0

# Enable FACK congestion avoidance and fast restransmission
net.ipv4.tcp_fack = 1

# DISABLE Allows TCP to send "duplicate" SACKs
net.ipv4.tcp_dsack = 0

# Controls IP packet forwarding
net.ipv4.ip_forward = 0

# No controls source route verification (RFC1812)
net.ipv4.conf.default.rp_filter = 0

# Enable fast recycling TIME-WAIT sockets
net.ipv4.tcp_tw_recycle = 1

# TODO : change TCP_SYNQ_HSIZE in include/net/tcp.h
# to keep TCP_SYNQ_HSIZE*16<=tcp_max_syn_backlog
net.ipv4.tcp_max_syn_backlog = 20000

# How may times to retry before killing TCP connection, closed by our side
net.ipv4.tcp_orphan_retries = 1

# how long to keep sockets in the state FIN-WAIT-2
# if we were the one closing the socket
net.ipv4.tcp_fin_timeout = 20

# maximum number of sockets in TIME-WAIT to be held simultaneously
net.ipv4.tcp_max_tw_buckets = $max_tw

# don't cache ssthresh from previous connection
net.ipv4.tcp_no_metrics_save = 1
net.ipv4.tcp_moderate_rcvbuf = 1

# increase Linux autotuning TCP buffer limits
net.ipv4.tcp_rmem = 4096 87380 16777216 
net.ipv4.tcp_wmem = 4096 65536 16777216

# increase TCP max buffer size
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216

net.core.netdev_max_backlog = 2500
net.core.somaxconn = 65000

vm.swappiness = 0

# Core dump suidsafe
fs.suid_dumpable = 2 

kernel.printk = 4 4 1 7
kernel.core_uses_pid = 1
kernel.sysrq = 0
kernel.msgmax = 65536
kernel.msgmnb = 65536
EOF

sysctl -p /etc/sysctl.conf