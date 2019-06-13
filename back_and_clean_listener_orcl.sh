#!/bin/bash

# +----------------------------------------------------------------------------+
# |                                                                            |
# | File Name    : back_and_clean_listener_orcl.sh                             |
# |                                                                            |
# | Author       : Quanwen Zhao                                                |
# |                                                                            |
# | Description  : This bash script file used to backup and clean listener     |
# |                                                                            |
# |                log file that located in "$ORACLE_BASE/diag/tnslsnr/        |
# |                                                                            |
# |                $HOSTNAME/listener/trace" directory on oracle user of Oracle|
# |                                                                            |
# |                Database Server.                                            |
# |                                                                            |
# | Call Syntax  : . ~/back_and_clean_listener_orcl.sh                         |
# |                                                                            |
# |                or                                                          |
# |                                                                            |
# |                sh ~/back_and_clean_listener_orcl.sh                        |
# |                                                                            |
# | Last Modified: 05/22/2017 (mm/dd/yyyy)                                     |
# |                                                                            |
# +----------------------------------------------------------------------------+

# +----------------------------------------------------------------------------+
# |                                                                            |
# | EXPORT ENVIRONMENT VARIABLE OF ORACLE USER                                 |
# |                                                                            |
# +----------------------------------------------------------------------------+

source ~/.bash_profile;

# +----------------------------------------------------------------------------+
# |                                                                            |
# | DEFINE SOME SHELL STRING VARIABLES ON ABSOLUTE PATH OF EXTERNAL COMMAND    |
# |                                                                            |
# | AND DIRECTORY                                                              |
# |                                                                            |
# +----------------------------------------------------------------------------+ 

export CUT=`which cut`

export DATE=`which date`

export DU=`which du`

export HOSTNAME=`which hostname`

export MV=`which mv`

export LSNRCTL=$ORACLE_HOME/bin/lsnrctl

export TRACE=$ORACLE_BASE/diag/tnslsnr/`$HOSTNAME`/listener/trace

# +----------------------------------------------------------------------------+
# |                                                                            |
# | CALCULATE THE SIZE OF LISTENER.LOG                                         |
# |                                                                            |
# +----------------------------------------------------------------------------+

export SIZE=`$DU -m $TRACE/listener.log | $CUT -f1`

# +----------------------------------------------------------------------------+
# |                                                                            |
# | IF THE SIZE OF LISTENER.LOG IS GREATER AND EQUAL THAN 512MB,THEN BACKUP    |
# |                                                                            |
# | AND CLEAN THE CONTENT OF IT,OTHERWISE RESERVE.                             |
# |                                                                            |
# +----------------------------------------------------------------------------+

if [ $SIZE -ge 512 ]; then

  $LSNRCTL set log_status off

  $MV $TRACE/listener.log $TRACE/listener_orcl_`$DATE +%Y%m%d%H%M%S`.log

  $LSNRCTL set log_status on

fi
