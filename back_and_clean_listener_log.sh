#!/bin/bash

# +----------------------------------------------------------------------------+
# |                                                                            |
# | File Name    : back_and_clean_listener_log.sh                              |
# |                                                                            |
# | Author       : Quanwen Zhao                                                |
# |                                                                            |
# | Description  : This bash script file used to backup and clean listener     |
# |                                                                            |
# |                log file that located in "$ORACLE_BASE/diag/tnslsnr/        |
# |                                                                            |
# |                $HOSTNAME/listener/trace" directory on oracle user of       |
# |                                                                            |
# |                Oracle Database Server.                                     |
# |                                                                            |
# | Call Syntax  : . ~/back_and_clean_listener_log.sh                          |
# |                                                                            |
# |                or                                                          |
# |                                                                            |
# |                sh ~/back_and_clean_listener_log.sh                         |
# |                                                                            |
# | Last Modified: 22/05/2017 (dd/mm/yyyy)                                     |
# |                                                                            |
# | Updated:       13/06/2019 (dd/mm/yyyy)                                     |
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
# | IF THE SIZE OF LISTENER.LOG IS GREATER THAN 512 MB, THEN BACKUP AND CLEAN  |
# |                                                                            |
# | ITS CURRENT CONTENT, OTHERWISE DO NOTHING.                                 |
# |                                                                            |
# +----------------------------------------------------------------------------+

if [ $SIZE -gt 512 ]; then

  $LSNRCTL set log_status off

  $MV $TRACE/listener.log $TRACE/listener_orcl_`$DATE +%Y%m%d%H%M%S`.log

  $LSNRCTL set log_status on

fi
