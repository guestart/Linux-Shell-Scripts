#!/bin/bash

# +------------------------------------------------------------------------+
# |                              Quanwen Zhao                              |
# |                            guestart@163.com                            |
# |                        guestart.blog.51cto.com                         |
# |------------------------------------------------------------------------|
# |      Copyright (c) 2016-2017 Quanwen Zhao. All rights reservered.      |
# |------------------------------------------------------------------------|
# | DATABASE   : Oracle                                                    |
# | OS ENV     : CentOS 6.6 X86_64 Bit                                     |
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
# | MODIFIED   : 02/13/2017 (dd/mm/yyyy)                                   |
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

export AWK='/bin/awkexport CUT='/bin/cut'
export DATE='/bin/date'
export DF='/bin/df'
export DU='/usr/bin/du'
export ECHO='/bin/echo'
export EXPR='/usr/bin/expr'
export LS='/bin/ls'
export RM='/bin/rm'
export SCP='/usr/bin/scp'
export SCRIPT='/usr/bin/script'
export SSH='/usr/bin/ssh'
export UNIQ='/usr/bin/uniq'

# +------------------------------------------------------------------------+
# | SWITCH CURRENT DIRECTORY TO EXPDP DIRECTORY OF ORACLE USER WITH CD     |
# +------------------------------------------------------------------------+

cd /u01/oradata/rman_back/expdp

# +------------------------------------------------------------------------+
# | GLOBAL VARIABLES ABOUT THE BACKTICK EXECUTION RESULT OF THE SHELL      |
# +------------------------------------------------------------------------+

export CURRENT_DATE=`$DATE +%Y%m%d`
export EXPDP_DMP=`$LS *.dmp | $CUT -d'_' -f5 | $UNIQ`
export EXPDP_TOTAL_SIZE_M=`$DU -m *\`$DATE +%Y%m%d\`* | $CUT -f1 | $AWK '{sum += $1};END {print sum}'`

# +------------------------------------------------------------------------+
# | GLOBAL VARIABLES ABOUT STRINGS AND ABSOLUTE PATH OF THE SHELL COMMAND  |
# +------------------------------------------------------------------------+

export DISK_ARRAY='HDA HDB HDC HDD HDE HDF HDG HDH HDI HDJ HDK HDL HDM HDN HDO HDP'
export SCP_LOG_LOCATION='/u01/oradata/rman_back/scp_expdp_log'

# +------------------------------------------------------------------------+
# | GLOBAL FUNCTIONS                                                       |
# +------------------------------------------------------------------------+

function scp_expdp_parallel () {

    for i in $DISK_ARRAY;
    do
      AVAIL_DISK_SIZE_M=`$SSH oracle@172.16.20.22 $DF -m | grep $i | $AWK '{print $4}'`
      if [ `$EXPR $AVAIL_DISK_SIZE_M / 1024` -gt `$EXPR $EXPDP_TOTAL_SIZE_M /1024` ]; then
        for j in $EXPDP_DMP;
        do
          EXPDP_DATE=`$ECHO $j | $CUT -c 1-8`
          if [ $EXPDP_DATE -eq $CURRENT_DATE ]; then
            $SCRIPT -a $SCP_LOG_LOCATION/scp_expdp_`date +%Y%m%d%H%M%S`.log -c "$SCP -p expdp_$j* oracle@172.16.20.22:/$i"
          else
            $RM -rf expdp_$j*
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

