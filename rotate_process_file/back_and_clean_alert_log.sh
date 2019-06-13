#!/bin/bash

# crontab setting on linux is as follows:

# 30 01 * * * ~/back_and_clean_alert_log.sh >>/dev/null 2>&1

# +---------------------------------------------------------------------+
# |                                                                     |
# | File Name    : back_and_clean_alert_log.sh                          |
# |                                                                     |
# | Author       : Quanwen Zhao                                         |
# |                                                                     |
# | Description  : This bash script file used to backup and clean alert |
# |                                                                     |
# |                log file that located in "$ORACLE_BASE/diag/rdbms/   |
# |                                                                     |
# |                orcl/orcl/trace" directory of oracle db server.      |
# |                                                                     |
# |                Assume that my oracle database name is "orcl".       |
# |                                                                     |
# | Call Syntax  : . ~/back_and_clean_alert_log.sh                      |
# |                                                                     |
# |                or                                                   |
# |                                                                     |
# |                sh ~/back_and_clean_alert_log.sh                     |
# |                                                                     |
# | Last Modified: 08/09/2016 (dd/mm/yyyy)                              |
# |                                                                     |
# | Updated:       13/06/2019 (dd/mm/yyyy)                              |
# |                                                                     |
# +---------------------------------------------------------------------+

# +--------------------------------------------+
# |                                            |
# | Export environment variable of oracle user |
# |                                            |
# +--------------------------------------------+

source ~/.bash_profile;

# +-----------------------------------------------------------------+
# |                                                                 |
# | Define some shell string variables on absolute path of external |
# |                                                                 |
# | command and directory                                           |
# |                                                                 |
# +-----------------------------------------------------------------+

export DU=`which du`

export CUT=`which cut`

export CP=`which cp`

export DATE=`which date`

export ECHO=`which echo`

export TRACE=$ORACLE_BASE/diag/rdbms/orcl/orcl/trace


# +----------------------------------------+
# |                                        |
# | Calculate the size of "alert_orcl.log" |
# |                                        |
# +----------------------------------------+

export SIZE=`$DU -m $TRACE/alert_orcl.log | $CUT -f1`

# +---------------------------------------------------------+
# |                                                         |
# | If the size of "alert_orcl.log" is greater than 150 MB, |
# |                                                         |
# | then backup and clean its current content, otherwise do |
# |                                                         |
# | nothing.                                                |
# |                                                         |
# +---------------------------------------------------------+

if [ $SIZE -gt 150 ]; then

  $CP $TRACE/alert_orcl.log $TRACE/alert_orcl_`$DATE +%Y%m%d%H%M%S`.log
  
  $ECHO "" > $TRACE/alert_orcl.log
  
fi
