#!/bin/bash

# +-----------------------------------------------------------------------+
# |                              Quanwen Zhao                             |
# |                            guestart@163.com                           |
# |                        quanwenzhao.wordpress.com                      |
# |-----------------------------------------------------------------------|
# |      Copyright (c) 2016-2017 Quanwen Zhao. All rights reserved.       |
# |-----------------------------------------------------------------------|
# | DATABASE   : Oracle                                                   |
# | OS ENV     : CentOS 6.6 X86_64 Bit                                    |
# | File       : rman_validate_v2.sh                                      |
# | CLASS      : LINUX Bourne-Again Shell Scripts                         |
# | PURPOSE    : This bash script file used to validate rman backupset    |
# |              that is generated last night via validate command on     |
# |              Oracle Database Server.                                  |
# |                                                                       |
# | PARAMETERS : None.                                                    |
# |                                                                       |
# | MODIFIED   : 03/17/2017 (mm/dd/yyyy)                                  |
# |                                                                       |
# | NOTE       : As with any code, ensure to test this script in a        |
# |              development environment before attempting to run it in   |
# |              production.                                              |
# +-----------------------------------------------------------------------+

# +-----------------------------------------------------------------------+
# | EXPORT ENVIRONMENT VARIABLE OF ORACLE USER                            |
# +-----------------------------------------------------------------------+

source ~/.bash_profile;

# +-----------------------------------------------------------------------+
# | GLOBAL VARIABLES ABOUT THE ABSOLUTE PATH OF THE SHELL COMMAND         |
# +-----------------------------------------------------------------------+

export AWK=`which awk`
export DATE=`which date`
export ECHO=`which echo`

# +-----------------------------------------------------------------------+
# | GLOBAL VARIABLES ABOUT STRINGS AND BACKTICK EXECUTION RESULT OF SHELL |
# +-----------------------------------------------------------------------+

export BACK_LOG=~/rman_backup/log
export RMAN=$ORACLE_HOME/bin/rman
export SQLPLUS=$ORACLE_HOME/bin/sqlplus
export YESTERDAY=`$DATE +%Y-%m-%d -d yesterday`
export DAY_OF_WEEK=`$DATE +%u`
export BSKEY_LIST=
export BSKEY_LIST_WITH_COMMA=

# +-----------------------------------------------------------------------+
# | QUERY ALL OF BS_KEY VALUE OF RMAN BACKUPSET YESTERDAY INTO BSKEY_LIST |
# +-----------------------------------------------------------------------+

BSKEY_LIST=`
$SQLPLUS -S /nolog << EOF
connect / as sysdba
set echo off feedback off heading off underline off
select bs_key from v\\$backup_set_details where device_type='DISK' and completion_time > to_date('$YESTERDAY','yyyy-mm-dd') order by 1;
exit;
EOF`

# +-----------------------------------------------------------------------+
# | WITH AWK COMMAND TO PROCESS BSKEY_LIST SAVE TO BSKEY_LIST_WITH_COMMA  |
# +-----------------------------------------------------------------------+

BSKEY_LIST_WITH_COMMA=`$ECHO $BSKEY_LIST | $AWK -F' ' '{ for ( i=1; i<NF; i++ ) print $i","; print $NF }'`

# +-----------------------------------------------------------------------+
# | VALIDATE RMAN BACKUPSET THAT IS GENERATED LAST NIGHT                  |
# +-----------------------------------------------------------------------+

case $DAY_OF_WEEK in

6)

$RMAN nocatalog log $BACK_LOG/validate_`$DATE +%Y-%m-%d`.log <<EOF
connect target /
run {
allocate channel d1 type disk maxpiecesize 16g;
allocate channel d2 type disk maxpiecesize 16g;
allocate channel d3 type disk maxpiecesize 16g;
allocate channel d4 type disk maxpiecesize 16g;
validate backupset $BSKEY_LIST_WITH_COMMA check logical;
release channel d4;
release channel d3;
release channel d2;
release channel d1;
}
exit;
EOF
;;

1|2|3|4|5|7)

$RMAN nocatalog log $BACK_LOG/validate_`$DATE +%Y-%m-%d`.log <<EOF
connect target /
validate backupset $BSKEY_LIST_WITH_COMMA check logical;
exit;
EOF
;;
esac
