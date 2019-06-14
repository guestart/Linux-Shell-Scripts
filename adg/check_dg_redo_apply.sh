#!/bin/bash

# The crontab setting on oracle user of linux server is as follows:

# 00 08 * * * /u01/oradata/script/check_dg_redo_apply/check_dg_redo_apply.sh

# +-----------------------------------------------------------------------+
# |                              Quanwen Zhao                             |
# |                            guestart@163.com                           |
# |                       quanwenzhao.wordpress.com                       |
# |-----------------------------------------------------------------------|
# |      Copyright (c) 2016-2017 Quanwen Zhao. All rights reserved.       |
# |-----------------------------------------------------------------------|
# | DATABASE   : Oracle DataGuard physical standby                        |
# | OS ENV     : Linux                                                    |
# | File       : check_dg_redo_apply.sh                                   |
# | CLASS      : Linux bash script                                        |
# | PURPOSE    : This bash script file used to check oracle dg physical   |
# |              standby database's redo apply situation.                 |
# |                                                                       |
# | PARAMETERS : None.                                                    |
# |                                                                       |
# | MODIFIED   : 10/07/2017 (dd/mm/yyyy)                                  |
# |                                                                       |
# | NOTE       : As with any code,ensure to test this script in a         |
# |              development environment before attempting to run it in   |
# |              production.                                              |
# +-----------------------------------------------------------------------+

# +-----------------------------------------------------------------------+
# | EXPORT ENVIRONMENT VARIABLE OF ORACLE USER                            |
# +-----------------------------------------------------------------------+

source ~/.bash_profile;

# +-----------------------------------------------------------------------+
# | GLOBAL VARIABLES ABOUT STRINGS AND BACKTICK EXECUTION RESULT OF SHELL |
# +-----------------------------------------------------------------------+

export DATE=`which date`

export TODAY=`$DATE +%Y%m%d%H%M%S`
 
export SQLPLUS=$ORACLE_HOME/bin/sqlplus

# +-----------------------------------------------------------------------+
# | SWITCH CURRENT DIRECTORY TO '/u01/oradata/script/check_dg_redo_apply',|
# | AND CONNECT TO USER OF SYSTEM WITH SQLPLUS COMMAND,THEN EXECUTE SQL   |
# | SCRIPT FILE.                                                          |
# +-----------------------------------------------------------------------+

cd /u01/oradata/script/check_dg_redo_apply/

$SQLPLUS -S /@standby << EOF
SPOOL '/u01/oradata/script_log/dg_redo_apply_$TODAY.log'
start check_dg_redo_apply.sql
SPOOL OFF
exit;
EOF
