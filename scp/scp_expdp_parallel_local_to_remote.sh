#!/bin/bash

# The crontab setting on oracle user of local server is as follows:

# 00 05 * * * /u01/oradata01/rman_backup/scp_expdp_parallel_to_remote.sh >/dev/null 2>&1

# +------------------------------------------------------------------------+
# |                                                                        |
# |                              Quanwen Zhao                              |
# |                                                                        |
# |                            guestart@163.com                            |
# |                                                                        |
# |                        quanwenzhao.wordpress.com                       |
# |                                                                        |
# |------------------------------------------------------------------------|
# |                                                                        |
# |       Copyright (c) 2016-2019 Quanwen Zhao. All rights reserved.       |
# |                                                                        |
# |------------------------------------------------------------------------|
# |                                                                        |
# |  DATABASE   : Oracle                                                   |
# |                                                                        |
# |  FILE       : scp_expdp_parallel_to_remote.sh                          |
# |                                                                        |
# |  CLASS      : LINUX Bourne-Again Shell Script                          |
# |                                                                        |
# |  PURPOSE    : This bash script file used to copy several files that    |
# |                                                                        |
# |               is gerenated by oracle datapump tool with expdp command  |
# |                                                                        |
# |               from local to another linux server via scp (secure copy) |
# |                                                                        |
# |               which is a remote file copy program, and the premise is  |
# |                                                                        |
# |               to configure SSH mutual trust function between local and |
# |                                                                        |
# |               remote server, if it the two hosts configured SSH mutual |
# |                                                                        |
# |               trust function each other, you can directly use SSH      |
# |                                                                        |
# |               command to connect to another host from this one. Other- |
# |                                                                        |
# |               wise you will need to enter current user's password from |
# |                                                                        |
# |               local host, which will produce interaction. And if using |
# |                                                                        |
# |               shell script it's the most taboo to produce interaction. |
# |                                                                        |
# |  PARAMETERS : None.                                                    |
# |                                                                        |
# |  MODIFIED   : 01/28/2019 (dd/mm/yyyy)                                  |
# |                                                                        |
# |  NOTE       : As with any code, ensure to test this script in a        |
# |                                                                        |
# |               development environment before attempting to run it in   |
# |                                                                        |
# |               production.                                              |
# |                                                                        |
# +------------------------------------------------------------------------+

# +------------------------------------------------------------------------+
# |                                                                        |
# | EXPORT ENVIRONMENT VARIABLE OF ORACLE USER                             |
# |                                                                        |
# +------------------------------------------------------------------------+

source ~/.bash_profile

# +------------------------------------------------------------------------+
# |                                                                        |
# | GLOBAL VARIABLES ABOUT THE ABSOLUTE PATH OF THE SHELL COMMAND          |
# |                                                                        |
# +------------------------------------------------------------------------+

export AWK=`which awk`

export CUT=`which cut`

export DATE=`which date`

export DF=`which df`

export DU=`which du`

export ECHO=`which echo`

export EXPR=`which expr`

export GREP=`which grep`

export LS=`which ls`

export RM=`which rm`

export SCP=`which scp`

export SCRIPT=`which script`

export SSH=`which ssh`

export TEE=`which tee`

export UNIQ=`which uniq`

# +------------------------------------------------------------------------+
# |                                                                        |
# | CHANGE CURRENT DIRECTORY TO EXPDP DIRECTORY OF ORACLE USER WITH CD     |
# |                                                                        |
# +------------------------------------------------------------------------+

cd /u01/oradata/rman_backup/expdp

# +------------------------------------------------------------------------+
# |                                                                        |
# | GLOBAL VARIABLES ABOUT THE BACKTICK EXECUTION RESULT OF THE SHELL      |
# |                                                                        |
# +------------------------------------------------------------------------+

export CURRENT_DATE=`$DATE +%Y%m%d`

export EXPDP_DMP=`$LS *.dmp | $CUT -d'_' -f5 | $UNIQ`

export EXPDP_TOTAL_SIZE_M=`$DU -m *\`$DATE +%Y%m%d\`* | $CUT -f1 | $AWK '{sum += $1};END {print sum}'`

# +------------------------------------------------------------------------+
# |                                                                        |
# | GLOBAL VARIABLES ABOUT STRINGS AND ABSOLUTE PATH OF THE SHELL COMMAND  |
# |                                                                        |
# +------------------------------------------------------------------------+

# REMOTE DISK ARRAY IS "/u01/oradata".
# $ df -h
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/sda2       212G  5.6G  195G   3% /
# tmpfs            63G   72K   63G   1% /dev/shm
# /dev/sda1       190M   32M  149M  18% /boot
# /dev/sdb1        47T   42T  2.5T  95% /u01/oradata  <<==
#
# $ cd /u01/oradata/
# $ ls -lrth |less
# total 42T
# ......
# -rw-r--r--. 1 oracle oracle 16K Jan 29 04:27 xxxx_base_20190129040001.log
# -rw-r-----. 1 oracle oracle 31G Jan 29 04:27 xxxx_base_20190129040001_03.dmp
# -rw-r-----. 1 oracle oracle 31G Jan 29 04:27 xxxx_base_20190129040001_02.dmp
# -rw-r-----. 1 oracle oracle 99G Jan 29 04:27 xxxx_base_20190129040001_01.dmp
# -rw-r--r--. 1 oracle oracle 16K Jan 30 04:28 xxxx_base_20190130040001.log
# -rw-r-----. 1 oracle oracle 31G Jan 30 04:28 xxxx_base_20190130040001_03.dmp
# -rw-r-----. 1 oracle oracle 31G Jan 30 04:28 xxxx_base_20190130040001_02.dmp
# -rw-r-----. 1 oracle oracle 99G Jan 30 04:28 xxxx_base_20190130040001_01.dmp
# ......

export REMOTE_DISK_ARRAY='/u01/oradata'

export SCP_LOG_PATH='/u01/oradata01/rman_backup/scp_expdp_base_log'

export SCP_LOG_FILE=$SCP_LOG_PATH/scp_expdp_base_`$DATE +%Y%m%d%H%M%S`.log

# +------------------------------------------------------------------------+
# |                                                                        |
# | GLOBAL FUNCTIONS, ASSUME THAT REMOTE SERVER'S IP IS "192.168.1.2" AND  |
# |                                                                        |
# | LOCAL SERVER IS "192.168.1.1"                                          |
# |                                                                        |
# +------------------------------------------------------------------------+

function scp_expdp_parallel () {

    AVAIL_DISK_SIZE_M=`$SSH oracle@192.168.1.2 $DF -m | $GREP $REMOTE_DISK_ARRAY | $AWK '{print $4}'`
    
    if [ `$EXPR $AVAIL_DISK_SIZE_M / 1024` -gt `$EXPR $EXPDP_TOTAL_SIZE_M / 1024` ]; then
    
    for j in $EXPDP_DMP;
    
    do
    
      EXPDP_DATE=`$ECHO $j | $CUT -c 1-8`
      
      if [ $EXPDP_DATE -eq $CURRENT_DATE ]; then
      
        $SCRIPT -a $SCP_LOG_FILE -c "$SCP -p *$j* oracle@192.168.1.2:$REMOTE_DISK_ARRAY"
        
        if [ `$ECHO $?` -ne 0 ]; then
        
          $ECHO -e "\nRemote copy all of dmp and log files that are generated today failed. Please check error information from log file.\n" | $TEE -a $SCP_LOG_FILE
        
        fi
      
      fi
    
    done
    
    exit;
    
    else
      
      $ECHO -e "\nInsufficient disk space!!!";
    
    fi
}

# +------------------------------------------------------------------------+
# |                                                                        |
# | CALL FUNCTIONS                                                         |
# |                                                                        |
# +------------------------------------------------------------------------+

scp_expdp_parallel

# As you can see there're scp related log file and its stuff on it on local server.
# 
# [oracle@xxxx  ~]$ cd /u01/oradata01/rman_backup/
# [oracle@xxxx rman_backup]$  
# [oracle@xxxx rman_backup]$ cd scp_expdp_base_log/
# [oracle@xxxx scp_expdp_base_log]$ 
# [oracle@xxxx scp_expdp_base_log]$ ls -lrth *
# ......
# -rw-r--r-- 1 oracle oinstall 117K Jan 29 08:56 scp_expdp_base_20190129083124.log
# -rw-r--r-- 1 oracle oinstall 117K Jan 30 05:24 scp_expdp_base_20190130050001.log
# ......
# [oracle@xxxx scp_expdp_base_log]$ 
# [oracle@xxxx scp_expdp_base_log]$ cat scp_expdp_base_20190129083124.log
# Script started on Tue 29 Jan 2019 05:00:02 AM CST
# xxxx_base_20190129040001_01.dmp       100%   99GB 110.7MB/s   15:11    
# xxxx_base_20190129040001_02.dmp       100%   31GB 110.9MB/s   04:46    
# xxxx_base_20190129040001_03.dmp       100%   30GB 111.0MB/s   04:40    
# xxxx_base_20190129040001.log          100%   15KB  12.0MB/s   00:00    
#
# Script done on Tue 29 Jan 2019 05:24:41 AM CST
# [oracle@xxxx scp_expdp_base_log]$ 
# [oracle@xxxx scp_expdp_base_log]$ cat scp_expdp_base_20190130050001.log 
# Script started on Wed 30 Jan 2019 05:00:02 AM CST
# xxxx_base_20190130040001_01.dmp       100%   99GB 110.6MB/s   15:12    
# xxxx_base_20190130040001_02.dmp       100%   30GB 110.7MB/s   04:41    
# xxxx_base_20190130040001_03.dmp       100%   31GB 110.8MB/s   04:44    
# xxxx_base_20190130040001.log          100%   15KB   4.7MB/s   00:00    
#
# Script done on Wed 30 Jan 2019 05:24:41 AM CST
