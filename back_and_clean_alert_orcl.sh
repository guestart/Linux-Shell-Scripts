#!/bin/bash
# +---------------------------------------------------------------------+
# |                                                                     |
# | File Name    : back_and_clean_alert_orcl.sh                         |
# |                                                                     |
# | Author       : Quanwen Zhao                                         |
# |                                                                     |
# | Description  : This bash script file used to backup and clean alert |
# |                                                                     |
# |                log file that located in "$ORACLE_BASE/diag/rdbms/   |
# |                                                                     |
# |                orcl/orcl/trace" directory of oracle db server.      |
# |                                                                     |
# | Call Syntax  : . ~/back_and_clean_alert_orcl.sh                     |
# |                                                                     |
# |                or                                                   |
# |                                                                     |
# |                sh ~/back_and_clean_alert_orcl.sh                    |
# |                                                                     |
# | Last Modified: 08/09/2016 (dd/mm/yyyy)                              |
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

# +--------------------------------------------------------+
# |                                                        |
# | If the size of "alert_orcl.log" is greater than 150 M, |
# |                                                        |
# | then backup "alert_orcl.log".                          |
# |                                                        |
# | and clean the content of it, otherwise reserve.        |
# |                                                        |
# +--------------------------------------------------------+

if [ $SIZE -gt 150 ]; then

  $CP $TRACE/alert_orcl.log $TRACE/alert_orcl_`$DATE +%Y%m%d%H%M%S`.log
  
  $ECHO "" > $TRACE/alert_orcl.log
  
fi
