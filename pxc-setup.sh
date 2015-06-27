#!/bin/bash

yum install -y wget

wget http://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
rpm -ivh epel-release-6-8.noarch.rpm

yum install -y socat

# rpm -Uhv http://www.percona.com/downloads/percona-release/percona-release-0.0-1.x86_64.rpm
# yum install -y Percona-Server-shared-51 Percona-XtraDB-Cluster-56 xinetd

yum install -y http://www.percona.com/downloads/percona-release/redhat/0.1-3/percona-release-0.1-3.noarch.rpm

yum install -y Percona-XtraDB-Cluster-server-55 Percona-XtraDB-Cluster-client-55 Percona-XtraDB-Cluster-galera-2 xinetd


echo '[mysqld]

datadir=/var/lib/mysql
user=mysql

# Path to Galera library
wsrep_provider=/usr/lib64/libgalera_smm.so

# Cluster connection URL contains the IPs of all possible nodes
wsrep_cluster_address=gcomm://172.28.128.11,172.28.128.12,172.28.128.13,172.28.128.14,172.28.128.15

# In order for Galera to work correctly binlog format should be ROW
binlog_format=ROW

# MyISAM storage engine has only experimental support
default_storage_engine=InnoDB

# This changes how InnoDB autoincrement locks are managed and is a requirement for Galera
innodb_autoinc_lock_mode=2

# Node address
wsrep_node_address='"$2"'

# SST method
# wsrep_sst_method=xtrabackup-v2
wsrep_sst_method=xtrabackup

# Cluster name
wsrep_cluster_name=tpt

# Authentication for SST method
wsrep_sst_auth="sstuser:s3cret"

wsrep_causal_reads=0
wsrep_auto_increment_control=0
auto_increment_increment=1
auto_increment_offset=1

# Small VM Optimizations
key_buffer_size                 = 16K
table_open_cache                = 256
sort_buffer_size                = 64K
read_buffer_size                = 256K
read_rnd_buffer_size            = 256K
net_buffer_length               = 2K
thread_stack                    = 262144
max_connections                 = 64
max_user_connections            = 64
max_allowed_packet              = 16M
max_connect_errors              = 1000000
innodb_strict_mode              = 1
innodb_lock_wait_timeout        = 3600
default_storage_engine          = InnoDB
innodb_buffer_pool_size         = 32M
innodb_additional_mem_pool_size = 2M
innodb_flush_log_at_trx_commit  = 2

' > /etc/my.cnf

if [ "$1" == '1' ]; then
  /etc/init.d/mysql bootstrap-pxc
  mysql -uroot -e "GRANT RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO 'sstuser'@'localhost' IDENTIFIED BY 's3cret';"
  mysql -uroot -e 'GRANT PROCESS ON *.* TO "clustercheckuser"@"localhost" IDENTIFIED BY "clustercheckpassword!";'
  mysql -uroot -e 'create database tpt_small;'
  mysql -uroot -e 'grant all on *.* to "root"@"%" identified by "123456";'
  mysql -uroot -e "FLUSH PRIVILEGES;"
else
  /etc/init.d/mysql start
fi

mysql -uroot -te "show status like 'wsrep%';" | egrep 'wsrep_cluster_size|wsrep_cluster_status|wsrep_connected|wsrep_local_state|Variable_name|\+'

echo 'mysqlchk 9200/tcp # mysqlchk' >> /etc/services
/etc/init.d/xinetd restart

chkconfig xinetd on
chkconfig mysql on


# Delay all outbound packets by 10 ± 50 ms
# to simulate network latency fluctuation
tc qdisc add dev eth1 root netem delay 10ms 50ms
