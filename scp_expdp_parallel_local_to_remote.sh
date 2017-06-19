#!/bin/bash

# +------------------------------------------------------------------------+
# |                              Quanwen Zhao                              |
# |                            guestart@163.com                            |
# |                        guestart.blog.51cto.com                         |
# |------------------------------------------------------------------------|
# |       Copyright (c) 2016-2017 Quanwen Zhao. All rights reserved.       |
# |------------------------------------------------------------------------|
# | DATABASE   : Oracle                                                    |
# | FILE       : scp_expdp_parallel_local_to_remote.sh                     |
# | CLASS      : LINUX Bourne-Again Shell Scripts                          |
# | PURPOSE    : This bash script file used to copy several files that     |
# |              is gerenated by oracle datapump tool with expdp command   |
# |              from local to another linux server via scp (secure copy)  |
# |              which is a remote file copy program,and the premise is    |
# |              to configure SSH mutual trust function between local and  | 
# |              remote server,because if it the two hosts configured SSH  |
# |              mutual trust function each other,you can directly use SSH |
# |              command to connect to another host from this one.Other-   |
# |              wise,you will need to enter current user's password from  |
# |              local host,which will produce interaction.And if using    |
# |              shell script,it is the most taboo to produce interaction. |
# |                                                                        |
# | PARAMETERS : None.                                                     |
# |                                                                        |
# | MODIFIED   : 03/17/2017 (dd/mm/yyyy)                                   |
# |                                                                        |
# | NOTE       : As with any code, ensure to test this script in a         |
# |              development environment before attempting to run it in    |
# |              production.                                               |
# +------------------------------------------------------------------------+

# +------------------------------------------------------------------------+
# | EXPORT ENVIRONMENT VARIABLE OF ORACLE USER                             |
# +------------------------------------------------------------------------+

source ~/.bash_profile

# +------------------------------------------------------------------------+
# | GLOBAL VARIABLES ABOUT THE ABSOLUTE PATH OF THE SHELL COMMAND          |
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
# | SWITCH CURRENT DIRECTORY TO EXPDP DIRECTORY OF ORACLE USER WITH CD     |
# +------------------------------------------------------------------------+

cd /u01/oradata/rman_backup/expdp

# +------------------------------------------------------------------------+
# | GLOBAL VARIABLES ABOUT THE BACKTICK EXECUTION RESULT OF THE SHELL      |
# +------------------------------------------------------------------------+

export CURRENT_DATE=`$DATE +%Y%m%d`
export EXPDP_DMP=`$LS *.dmp | $CUT -d'_' -f5 | $UNIQ`
export EXPDP_TOTAL_SIZE_M=`$DU -m *\`$DATE +%Y%m%d\`* | $CUT -f1 | $AWK '{sum += $1};END {print sum}'`

# +------------------------------------------------------------------------+
# | GLOBAL VARIABLES ABOUT STRINGS AND ABSOLUTE PATH OF THE SHELL COMMAND  |
# +------------------------------------------------------------------------+

export DISK_ARRAY='HDC HDD HDE HDF HDG HDH HDI HDJ HDK HDL HDM HDN'
export SCP_LOG_PATH='/u01/oradata01/rman_backup/scp_expdp_base_log'
export SCP_LOG_FILE=$SCP_LOG_PATH/scp_expdp_base_`$DATE +%Y%m%d%H%M%S`.log

# +------------------------------------------------------------------------+
# | GLOBAL FUNCTIONS                                                       |
# +------------------------------------------------------------------------+

function scp_expdp_parallel () {

  for i in $DISK_ARRAY;
  do
    AVAIL_DISK_SIZE_M=`$SSH oracle@10.103.0.22 $DF -m | $GREP $i | $AWK '{print $4}'`
    if [ `$EXPR $AVAIL_DISK_SIZE_M / 1024` -gt `$EXPR $EXPDP_TOTAL_SIZE_M / 1024` ]; then
    for j in $EXPDP_DMP;
    do
      EXPDP_DATE=`$ECHO $j | $CUT -c 1-8`
      if [ $EXPDP_DATE -eq $CURRENT_DATE ]; then
        $SCRIPT -a $SCP_LOG_FILE -c "$SCP -p expdp_szd_base_v2_$j* oracle@10.103.0.22:/$i"
        if [ `$ECHO $?` -ne 0 ]; then
          $ECHO -e "\nRemote copy all of dmp and log files that are generated today failed.Please check error information from log file.\n" | $TEE -a $SCP_LOG_FILE
        fi
      fi
    done
    exit;
    else
      continue;
    fi
  done

}

# +------------------------------------------------------------------------+
# | CALL FUNCTIONS                                                         |
# +------------------------------------------------------------------------+

scp_expdp_parallel
