#!/bin/bash

export ECHO=`which echo`
export SU=`which su`

export ORA_OWNER=oracle
export ORA_HOME=`$SU - ${ORA_OWNER} -c "dbhome"`
export ORA_LOGFILE=/var/log/oracle.log

$ECHO "$0 : (start oracle database ...)"
$SU - ${ORA_OWNER} -c "${ORA_HOME}/bin/dbstart ${ORA_HOME}" >> ${ORA_LOGFILE}

# You need invoke this SHELL script in /etc/rc.local in order to be able to
# automatically startup oracle database after restarting server.
# 
# Such as, the following demo:
# [root@prodb1 ~]# cat /etc/rc.local
# !/bin/sh
# 
# This script will be executed *after* all the other init scripts.
# You can put your own initialization stuff in here if you don't
# want to do the full Sys V style init stuff.
# 
# touch /var/lock/subsys/local
# 
# Startup rsyncd process
# /usr/bin/rsync --daemon --port=873 --config=/etc/rsyncd.conf >/dev/null 2>&1
# 
# Automatically Startup Oracle Database Instance after restarting server
# sh /home/oracle/automatically_open_oracle.sh
