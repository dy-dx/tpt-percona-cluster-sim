#!/bin/bash

yum install -y haproxy.x86_64

echo '
global
    log 127.0.0.1 local0
    log 127.0.0.1 local1 notice
    maxconn 4096
    chroot /usr/share/haproxy
    user haproxy
    group haproxy
    daemon
defaults
    log global
    mode http
    option tcplog
    option dontlognull
    retries 3
    option redispatch
    maxconn 2000
    contimeout 5000
    clitimeout 50000
    srvtimeout 50000

############------CLUSTER_FOR_WRITE--------##########################################
frontend tpt-write
    bind *:3306
    mode tcp
    timeout client 600s
    default_backend tpt-write
    backend tpt-write
    mode tcp
    timeout server 600s
    balance leastconn
    option httpchk
    option log-health-checks
    server pxc1 172.28.128.11:3306 check port 9200 inter 15000 rise 3 fall 3
    server pxc2 172.28.128.12:3306 check port 9200 inter 15000 rise 3 fall 3 backup
    server pxc3 172.28.128.13:3306 check port 9200 inter 15000 rise 3 fall 3 backup
    server pxc4 172.28.128.14:3306 check port 9200 inter 15000 rise 3 fall 3 backup
    server pxc5 172.28.128.15:3306 check port 9200 inter 15000 rise 3 fall 3 backup

##############------CLUSTER_FOR_READ--------########################################################
frontend tpt-read
    bind *:3307
    mode tcp
    default_backend tpt-read
    backend tpt-read
    mode tcp
    balance leastconn
    option httpchk
    option log-health-checks
    #server pxc1 172.28.128.11:3306 check port 9200 inter 15000 rise 3 fall 3
    server pxc2 172.28.128.12:3306 check port 9200 inter 15000 rise 3 fall 3
    server pxc3 172.28.128.13:3306 check port 9200 inter 15000 rise 3 fall 3
    server pxc4 172.28.128.14:3306 check port 9200 inter 15000 rise 3 fall 3
    server pxc5 172.28.128.15:3306 check port 9200 inter 15000 rise 3 fall 3

' > /etc/haproxy/haproxy.cfg

/etc/init.d/haproxy restart

chkconfig haproxy on
