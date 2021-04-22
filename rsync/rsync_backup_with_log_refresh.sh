#!/bin/bash

# The crontab setting on oracle user of local linux server is as follows:

# 00 03 * * * ~/rsync_script/rsync_backup_with_log_refresh.sh

# +-----------------------------------------------------------------------+
# |                              Quanwen Zhao                             |
# |                            guestart@163.com                           |
# |                       quanwenzhao.wordpress.com                       |
# |-----------------------------------------------------------------------|
# |      Copyright (c) 2021 - Quanwen Zhao. All rights reserved.          |
# |-----------------------------------------------------------------------|
# | DATABASE   : Oracle Database                                          |
# | OS ENV     : Linux                                                    |
# | File       : rsync_backup_with_log_refresh.sh                         |
# | CLASS      : Linux bash script                                        |
# | PURPOSE    : This bash script file uses to rsync oracle backup files  |
# |              from REMOTE server to local.                             |
# |                                                                       |
# | PARAMETERS : None.                                                    |
# |                                                                       |
# | MODIFIED   : 22/04/2021 (dd/mm/yyyy)                                  |
# |                                                                       |
# | NOTE       : As with any code,ensure to test this script in a         |
# |              development environment before attempting to run it in   |
# |              production.                                              |
# +-----------------------------------------------------------------------+

# +-----------------------------------------------------------------------+
# | GLOBAL VARIABLES ABOUT BACKTICK EXECUTION RESULT OF SHELL AND STRINGS |
# +-----------------------------------------------------------------------+

export AWK=`which awk`
export ECHO=`which echo`
export CUT=`which cut`
export DATE=`which date`
export DF=`which df`
export FIND=`which find`
export GREP=`which grep`
export RSYNC=`which rsync`
export SCRIPT=`which script`
export TEE=`which tee`

export DISK_USED_PERCENT=`$DF -h | $GREP "/DATA" | $AWK '{print $5}' | $CUT -d% -f1`

export RSYNC_LOG_FILE=~/rsync_script/rsync_log/rsync_`$DATE  +%Y%m%d-%H%M%S`.log
export RSYNC_LOG_DIR=~/rsync_script/rsync_log
export RSYNC_DIR=/DATA/rsync

if [ $DISK_USED_PERCENT -le 95 ]; then
  $SCRIPT -a $RSYNC_LOG_FILE -c "$RSYNC -rvlHpogDtS --progress oracle@xx.xxx.x.xx:/home/oracle/rman_backup /DATA/rsync"
  $SCRIPT -a $RSYNC_LOG_FILE -c "$RSYNC -rvlHpogDtS --progress oracle@xx.xxx.x.xx:/u01/app/oracle/expdp /DATA/rsync"
else
  $ECHO -e "\nDisk available free space is not enough! Please removing some expired files first and try to run this SHELL script.\n" | $TEE -a $RSYNC_LOG_FILE
fi

# Setting the retention policy (only retaining 168 days for backup files and rsync log files)
# and they will automatically be purged if which are in the outside of retention policy in
# order to avoid exhausting the disk space.
# Ref: https://www.cyberciti.biz/faq/find-command-exclude-ignore-files/

$FIND $RSYNC_DIR -type f -mtime +168 -exec rm -f {} \; 
$FIND $RSYNC_DIR -type d -empty -exec rmdir {} \;
$FIND $RSYNC_LOG_DIR -type f -mtime +168 -exec rm -f {} \;
