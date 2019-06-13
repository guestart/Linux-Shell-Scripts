#!/bin/bash

# +-----------------------------------------------------------------------+
# |                                                                       |
# |                              Quanwen Zhao                             |
# |                                                                       |
# |                            guestart@163.com                           |
# |                                                                       |
# |                        quanwenzhao.wordpress.com                      |
# |                                                                       |
# |-----------------------------------------------------------------------|
# |                                                                       |
# |      Copyright (c) 2016-2017 Quanwen Zhao. All rights reserved.       |
# |                                                                       |
# |-----------------------------------------------------------------------|
# |                                                                       |
# | DATABASE   : Oracle                                                   |
# |                                                                       |
# | OS ENV     : Linux                                                    |
# |                                                                       |
# | File       : collect_info_from_source_oracle.sh                       |
# |                                                                       |
# | CLASS      : LINUX Bourne-Again Shell Scripts                         |
# |                                                                       |
# | PURPOSE    : This bash script file used to collect some information   |
# |                                                                       |
# |              from local oracle database server, and save them to a    |
# |                                                                       |
# |              log file.                                                |
# |                                                                       |
# |                                                                       |
# | PARAMETERS : None.                                                    |
# |                                                                       |
# | MODIFIED   : 03/10/2017 (mm/dd/yyyy)                                  |
# |                                                                       |
# | NOTE       : As with any code, ensure to test this script in a        |
# |                                                                       |
# |              development environment before attempting to run it in   |
# |                                                                       |
# |              production.                                              |
# |                                                                       |
# +-----------------------------------------------------------------------+

# +-----------------------------------------------------------------------+
# |                                                                       |
# | EXPORT ENVIRONMENT VARIABLE OF ORACLE USER                            |
# |                                                                       |
# +-----------------------------------------------------------------------+

###########################################################################

source ~/.bash_profile;

###########################################################################

# +-----------------------------------------------------------------------+
# |                                                                       |
# | GLOBAL VARIABLES ABOUT STRINGS AND BACKTICK EXECUTION RESULT OF SHELL |
# |                                                                       |
# +-----------------------------------------------------------------------+

###########################################################################

export AWK=`which awk`
export CAT=`which cat`
export DATE=`which date`
export DU=`which du`
export ECHO=`which echo`
export GREP=`which grep`
export LS=`which ls`
export TEE=`which tee`
export TOUCH=`which touch`
export TR=`which tr`
export UNIQ=`which uniq`

###########################################################################

export LSNRCTL=$ORACLE_HOME/bin/lsnrctl
export SQLPLUS=$ORACLE_HOME/bin/sqlplus

###########################################################################

export YESTERDAY=`$DATE +%Y-%m-%d -d yesterday`

###########################################################################

export DBINFO=
export DBID=
export DBNAME=
export OSNAME=

###########################################################################

export HOST_AND_VER=
export HOST_NAME=
export DBVERSION=

###########################################################################

export ARCH_LOG=
export ARCH_LOG_PATH=
export ARCH_LOG_SIZE_M=
export ARCH_LOG_TOTAL_SIZE_M=

###########################################################################

export DB_FILE=
export DB_FILE_PATH=
export DB_FILE_SIZE_M=
export DB_FILE_TOTAL_SIZE_M=
export DBFILE_PATH='/tmp/dbfile_path.log'

###########################################################################

export BLOCK_CHANGE_TRACKING_FILE=
export BLOCK_CHANGE_TRACKING_FILE_DIR=
export BLOCK_CHANGE_TRACKING_FILE_PATH=
export BLOCK_CHANGE_TRACKING_FILE_SIZE_M=

###########################################################################

export FAST_OR_FLASH_RECO_AREA=
export FAST_OR_FLASH_RECO_AREA_PATH=

###########################################################################

export RMAN_BACK=
export RMAN_BACK_PATH=
export RMAN_BACK_SIZE_M=
export RMAN_BACK_TOTAL_SIZE_M=
export RMANBACK_PATH='/tmp/rmanback_path.log'

###########################################################################

export RMAN_LATEST_SPFILE=
export RMAN_LATEST_SPFILE_DIR=
export RMAN_LATEST_SPFILE_PATH=
export RMAN_LATEST_SPFILE_SIZE_M=

###########################################################################

export RMAN_LATEST_CTL_FILE=
export RMAN_LATEST_CTL_FILE_DIR=
export RMAN_LATEST_CTL_FILE_PATH=
export RMAN_LATEST_CTL_FILE_SIZE_M=

###########################################################################

export LISTENER_FILE_PATH=

###########################################################################

export BASE_ADMIN_DBNAME_DIR=

###########################################################################

export PASSWORD_FILE_PATH=

###########################################################################

export ORACLE_SERVICE_NAME=
export ORACLE_SERVICE_NAME_VALUE=

###########################################################################

export SOURCE_DBINFO='/tmp/source_oracle_dbinfo.log'
export LOGFILE="/tmp/collect_info_from_source_oracle_`$DATE +%F-%H-%M-%S`.log"

###########################################################################

# +-----------------------------------------------------------------------+
# |                                                                       |
# | QUERY VALUE OF DBID,DBNAME AND OSNAME                                 |
# |                                                                       |
# +-----------------------------------------------------------------------+

###########################################################################

function query_dbinfo () {

DBINFO=`$SQLPLUS -S / as sysdba << EOF
set echo off feedback off heading off underline off;
select dbid || ',' || lower(name) || ',' || platform_name as dbinfo from v\\$database;
exit;
EOF`

DBID=`$ECHO $DBINFO | $AWK -F',' '{ print $1 }'`
DBNAME=`$ECHO $DBINFO | $AWK -F',' '{ print $2 }'`
OSNAME=`$ECHO $DBINFO | $AWK -F',' '{ print $3 }'`

}

###########################################################################

# +-----------------------------------------------------------------------+
# |                                                                       |
# | QUERY VALUE OF HOST_NAME AND DBVERSION                                |
# |                                                                       |
# +-----------------------------------------------------------------------+

###########################################################################

function query_hostname_and_dbver () {

HOST_AND_VER=`$SQLPLUS -S / as sysdba << EOF
set echo off feedback off heading off underline off;
select host_name || ',' || version from v\\$instance;
exit;
EOF`

HOST_NAME=`$ECHO $HOST_AND_VER | $AWK -F',' '{ print $1 }'`
DBVERSION=`$ECHO $HOST_AND_VER | $AWK -F',' '{ print $2 }'`

}

###########################################################################

# +-----------------------------------------------------------------------+
# |                                                                       |
# | QUERY PATH AND TOTAL SIZE (MB) OF ARCHIVE LOG                         |
# |                                                                       |
# +-----------------------------------------------------------------------+

###########################################################################

function query_arch_log () {

ARCH_LOG=`$SQLPLUS -S / as sysdba << EOF
set echo off feedback off heading off underline off;
select distinct destination from v\\$archive_dest order by 1;
exit;
EOF`

ARCH_LOG_PATH=`$ECHO $ARCH_LOG | $AWK '{ print $1 }'`
ARCH_LOG_SIZE_M=`$DU -sm $ARCH_LOG_PATH | $AWK '{ print $1 }'`
ARCH_LOG_TOTAL_SIZE_M=`$ECHO $ARCH_LOG_SIZE_M | $AWK '{ sum=0;for(i=1;i<=NF;i++) {sum+=$i} print sum }'`

}

###########################################################################

# +-----------------------------------------------------------------------+
# |                                                                       |
# | QUERY PATH AND TOTAL SIZE (MB) OF DB FILE (DATA FILE AND TEMP FILE)   |
# |                                                                       |
# +-----------------------------------------------------------------------+

###########################################################################

function query_db_file () {

DB_FILE=`$SQLPLUS -S / as sysdba << EOF
set echo off feedback off heading off underline off;
select name from v\\$datafile union all select name from v\\$tempfile;
exit;
EOF`

if [ ! -f "$DBFILE_PATH" ]; then
  $TOUCH "$DBFILE_PATH"
else
  > "$DBFILE_PATH"
fi

for name in ${DB_FILE[@]}
do
  $ECHO ${name%/*} >> $DBFILE_PATH
done

DB_FILE_PATH=`$CAT $DBFILE_PATH | $UNIQ | $TR '\n' ' '`
DB_FILE_SIZE_M=`$DU -sm $DB_FILE_PATH | $AWK '{ print $1 }'`
DB_FILE_TOTAL_SIZE_M=`$ECHO $DB_FILE_SIZE_M | $AWK '{ sum=0;for(i=1;i<=NF;i++) {sum+=$i} print sum }'`

}

###########################################################################

# +-----------------------------------------------------------------------+
# |                                                                       |
# | QUERY PATH,DIR AND SIZE (MB) OF BLOCK CHANGE TRACKING FILE            |
# |                                                                       |
# +-----------------------------------------------------------------------+

###########################################################################

function query_block_change_tracking_file () {

BLOCK_CHANGE_TRACKING_FILE=`$SQLPLUS -S / as sysdba << EOF
set echo off feedback off heading off underline off;
select filename from v\\$block_change_tracking;
exit;
EOF`

BLOCK_CHANGE_TRACKING_FILE_PATH=`$ECHO $BLOCK_CHANGE_TRACKING_FILE | $AWK '{ print $1 }'`

if [ -z "$BLOCK_CHANGE_TRACKING_FILE_PATH" ]; then
  BLOCK_CHANGE_TRACKING_FILE_PATH=""
  BLOCK_CHANGE_TRACKING_FILE_DIR=""
  BLOCK_CHANGE_TRACKING_FILE_SIZE_M=0
else
  BLOCK_CHANGE_TRACKING_FILE_DIR=`$ECHO ${BLOCK_CHANGE_TRACKING_FILE_PATH%/*}`
  BLOCK_CHANGE_TRACKING_FILE_SIZE_M=`$DU -sm $BLOCK_CHANGE_TRACKING_FILE_PATH | $AWK '{ print $1 }'`
fi

}

###########################################################################

# +-----------------------------------------------------------------------+
# |                                                                       |
# | QUERY PATH OF FAST OR FLASH RECO AREA                                 |
# |                                                                       |
# +-----------------------------------------------------------------------+

###########################################################################

function query_fast_or_flash_reco_area () {

FAST_OR_FLASH_RECO_AREA=`$SQLPLUS -S / as sysdba << EOF
set echo off feedback off heading off underline off;
select value from v\\$parameter where name='db_recovery_file_dest';
exit;
EOF`

FAST_OR_FLASH_RECO_AREA_PATH=`$ECHO $FAST_OR_FLASH_RECO_AREA`

if [ -z "$FAST_OR_FLASH_RECO_AREA_PATH" ]; then
  FAST_OR_FLASH_RECO_AREA_PATH=""
fi

}

###########################################################################

# +-----------------------------------------------------------------------+
# |                                                                       |
# | QUERY PATH AND TOTAL SIZE (MB) OF ALL OF RMAN BACKUPSETS              |
# |                                                                       |
# | (EXCLUDE RMAN BACKUP SPFILE AND RMAN BACKUP CONTROL FILE)             |
# |                                                                       |
# +-----------------------------------------------------------------------+

###########################################################################

function query_rman_back () {

RMAN_BACK=`$SQLPLUS -S / as sysdba << EOF
set echo off feedback off heading off underline off;
select distinct p.handle from v\\$backup_piece_details p,v\\$backup_set_details s
where p.bs_key=s.bs_key
and p.status='A'
and p.device_type='DISK'
and s.controlfile_included='NO'
order by 1;
exit;
EOF`

if [ ! -f "$RMANBACK_PATH" ]; then
  $TOUCH "$RMANBACK_PATH"
else
  > "$RMANBACK_PATH"
fi

for name in ${RMAN_BACK[@]}
do
  $ECHO ${name%/*} >> $RMANBACK_PATH
done

RMAN_BACK_PATH=`$CAT $RMANBACK_PATH | $UNIQ | $TR '\n' ' '`
RMAN_BACK_SIZE_M=`$DU -sm $RMAN_BACK_PATH | $AWK '{ print $1 }'`
RMAN_BACK_TOTAL_SIZE_M=`$ECHO $RMAN_BACK_SIZE_M | $AWK '{ sum=0;for(i=1;i<=NF;i++) {sum+=$i} print sum }'`

}

###########################################################################

# +-----------------------------------------------------------------------+
# |                                                                       |
# | QUERY PATH,DIR AND SIZE (MB) OF THE LATEST RMAN BACKUP SPFILE         |
# |                                                                       |
# +-----------------------------------------------------------------------+

function query_rman_latest_spfile () {

RMAN_LATEST_SPFILE=`$SQLPLUS -S / as sysdba << EOF
set echo off feedback off heading off underline off;
select distinct p.handle from v\\$backup_piece_details p,v\\$backup_spfile sp,v\\$backup_spfile_details s
where p.bs_key=s.bs_key
and p.status='A'
and p.device_type='DISK'
and p.completion_time > to_date ('$YESTERDAY','yyyy-mm-dd')
order by 1;
exit;
EOF`

RMAN_LATEST_SPFILE_PATH=`$ECHO $RMAN_LATEST_SPFILE | $AWK '{ print $1 }'`
RMAN_LATEST_SPFILE_DIR=`$ECHO ${RMAN_LATEST_SPFILE_PATH%/*}`
RMAN_LATEST_SPFILE_SIZE_M=`$DU -sm $RMAN_LATEST_SPFILE_PATH | $AWK '{ print $1 }'`

}

###########################################################################

# +-----------------------------------------------------------------------+
# |                                                                       |
# | QUERY PATH,DIR AND SIZE (MB) OF THE LATEST RMAN BACKUP CONTROL FILE   |
# |                                                                       |
# +-----------------------------------------------------------------------+

###########################################################################

function query_rman_latest_ctl_file () {

RMAN_LATEST_CTL_FILE=`$SQLPLUS -S / as sysdba << EOF
set echo off feedback off heading off underline off;
select distinct p.handle from v\\$backup_piece_details p,v\\$backup_set_details s
where p.bs_key=s.bs_key
and p.status='A'
and p.device_type='DISK'
and s.controlfile_included='YES'
and s.completion_time > to_date ('$YESTERDAY','yyyy-mm-dd')
order by 1;
exit;
EOF`

RMAN_LATEST_CTL_FILE_PATH=`$ECHO $RMAN_LATEST_CTL_FILE | $AWK '{ print $1 }'`
RMAN_LATEST_CTL_FILE_DIR=`$ECHO ${RMAN_LATEST_CTL_FILE_PATH%/*}`
RMAN_LATEST_CTL_FILE_SIZE_M=`$DU -sm $RMAN_LATEST_CTL_FILE_PATH | $AWK '{ print $1 }'`

}

###########################################################################

# +-----------------------------------------------------------------------+
# |                                                                       |
# | QUERY PATH OF ORACLE LISTENER FILE                                    |
# |                                                                       |
# +-----------------------------------------------------------------------+

###########################################################################

LISTENER_FILE_PATH=`$LSNRCTL status | $GREP "Listener Parameter File" | $AWK '{ print $4 }'`

###########################################################################

# +-----------------------------------------------------------------------+
# |                                                                       |
# | PERFORM FOLLOWING TWO STEPS:                                          |
# |                                                                       |
# | 1. QUERY VALUE OF DBNAME BY FUNCTION 'query_dbinfo' WROTE ABOVE       |
# |                                                                       |
# | 2. QUERY VALUE OF STRING VARIABLE ABOUT BASE_ADMIN_DBNAME_DIR         |
# |                                                                       |
# +-----------------------------------------------------------------------+

###########################################################################

query_dbinfo

BASE_ADMIN_DBNAME_DIR=`$LS $ORACLE_BASE/admin/$DBNAME`

###########################################################################

# +-----------------------------------------------------------------------+
# |                                                                       |
# | QUERY PATH OF ORACLE PASSWORD FILE                                    |
# |                                                                       |
# +-----------------------------------------------------------------------+

###########################################################################

PASSWORD_FILE_PATH=`$LS $ORACLE_HOME/dbs/orapw$ORACLE_SID`

###########################################################################

function query_oracle_service_name () {

ORACLE_SERVICE_NAME=`$SQLPLUS -S / as sysdba << EOF
set echo off feedback off heading off underline off;
select value from v\\$parameter where name='service_names';
exit;
EOF`

ORACLE_SERVICE_NAME_VALUE=`$ECHO $ORACLE_SERVICE_NAME`

}

###########################################################################

# +-----------------------------------------------------------------------+
# |                                                                       |
# | PRINT SOME PROMPT MESSAGES AND VALUE OF FOLLOWING STRING VARIABLE TO  |
# |                                                                       |
# | COMPUTER SCREEN,AT THE SAME TIME,WRITE THEM TO A LOG FILE.            | 
# |                                                                       |
# | STRING VARIABLES AS FOLLWS:                                           |
# |                                                                       |
# | 1.HOSTNAME                                                            |
# |                                                                       |
# | 2.OSNAME                                                              |
# |                                                                       |
# | 3.DBVERSION                                                           |
# |                                                                       |
# | 4.DBNAME                                                              |
# |                                                                       |
# | 5.DBID                                                                |
# |                                                                       |
# | 6.ARCH_LOG_PATH                                                       |
# |                                                                       |
# | 7.ARCH_LOG_TOTAL_SIZE_M                                               |
# |                                                                       |
# | 8.DB_FILE_PATH                                                        |
# |                                                                       |
# | 9.DB_FILE_TOTAL_SIZE_M                                                |
# |                                                                       |
# | 10.BLOCK_CHANGE_TRACKING_FILE_PATH                                    |
# |                                                                       |
# | 11.BLOCK_CHANGE_TRACKING_FILE_DIR                                     |
# |                                                                       |
# | 12.BLOCK_CHANGE_TRACKING_FILE_SIZE_M                                  |
# |                                                                       |
# | 13.FAST_OR_FLASH_RECO_AREA_PATH                                       |
# |                                                                       |
# | 14.RMAN_BACK_PATH                                                     |
# |                                                                       |
# | 15.RMAN_BACK_TOTAL_SIZE_M                                             |
# |                                                                       |
# | 16.RMAN_LATEST_SPFILE_PATH                                            |
# |                                                                       |
# | 17.RMAN_LATEST_SPFILE_DIR                                             |
# |                                                                       |
# | 18.RMAN_LATEST_SPFILE_SIZE_M                                          |
# |                                                                       |
# | 19.RMAN_LATEST_CTL_FILE_PATH                                          |
# |                                                                       |
# | 20.RMAN_LATEST_CTL_FILE_DIR                                           |
# |                                                                       |
# | 21.RMAN_LATEST_CTL_FILE_SIZE_M                                        |
# |                                                                       |
# | 22.LISTENER_FILE_PATH                                                 |
# |                                                                       |
# | 23.BASE_ADMIN_DBNAME_DIR                                              |
# |                                                                       |
# | 24.PASSWORD_FILE_PATH                                                 |
# |                                                                       |
# | 25.ORACLE_BASE_PATH                                                   |
# |                                                                       |
# | 26.ORACLE_HOME_PATH                                                   |
# |                                                                       |
# | 27.ORACLE_SID                                                         |
# |                                                                       |
# | 28.ORACLE_SERVICE_NAME                                                |
# |                                                                       |
# +-----------------------------------------------------------------------+

###########################################################################

function print_info_to_file () {

if [ ! -f "$SOURCE_DBINFO" ]; then
  $TOUCH "$SOURCE_DBINFO"
else
  > "$SOURCE_DBINFO"
fi

$ECHO "#################################################################" | $TEE -a $LOGFILE
$ECHO "#                                                               #" | $TEE -a $LOGFILE
$ECHO "#  SOME BASIC INFORMATION OBTAINED FROM SOURCE ORACLE DATABASE  #" | $TEE -a $LOGFILE
$ECHO "#  SERVER AS FOLLOWS:                                           #" | $TEE -a $LOGFILE
$ECHO "#                                                               #" | $TEE -a $LOGFILE
$ECHO -e "#################################################################\n" | $TEE -a $LOGFILE
$ECHO 'HOSTNAME:'$HOST_NAME | $TEE -a $SOURCE_DBINFO
$ECHO 'OSNAME:'$OSNAME | $TEE -a $SOURCE_DBINFO
$ECHO 'DBVERSION:Oracle '$DBVERSION | $TEE -a $SOURCE_DBINFO
$ECHO 'DBNAME:'$DBNAME | $TEE -a $SOURCE_DBINFO
$ECHO 'DBID:'$DBID | $TEE -a $SOURCE_DBINFO
$ECHO 'ARCH_LOG_PATH:'$ARCH_LOG_PATH | $TEE -a $SOURCE_DBINFO
$ECHO 'ARCH_LOG_TOTAL_SIZE(MB):'$ARCH_LOG_TOTAL_SIZE_M | $TEE -a $SOURCE_DBINFO
$ECHO 'DB_FILE_PATH:'$DB_FILE_PATH | $TEE -a $SOURCE_DBINFO
$ECHO 'DB_FILE_TOTAL_SIZE(MB):'$DB_FILE_TOTAL_SIZE_M | $TEE -a $SOURCE_DBINFO
$ECHO 'BLOCK_CHANGE_TRACKING_FILE_PATH:'$BLOCK_CHANGE_TRACKING_FILE_PATH | $TEE -a $SOURCE_DBINFO
$ECHO 'BLOCK_CHANGE_TRACKING_FILE_DIR:'$BLOCK_CHANGE_TRACKING_FILE_DIR | $TEE -a $SOURCE_DBINFO
$ECHO 'BLOCK_CHANGE_TRACKING_FILE_SIZE(MB):'$BLOCK_CHANGE_TRACKING_FILE_SIZE_M | $TEE -a $SOURCE_DBINFO
$ECHO 'FAST_OR_FLASH_RECO_AREA_PATH:'$FAST_OR_FLASH_RECO_AREA_PATH | $TEE -a $SOURCE_DBINFO
$ECHO 'RMAN_BACK_PATH:'$RMAN_BACK_PATH | $TEE -a $SOURCE_DBINFO
$ECHO 'RMAN_BACK_TOTAL_SIZE(MB):'$RMAN_BACK_TOTAL_SIZE_M | $TEE -a $SOURCE_DBINFO
$ECHO 'RMAN_LATEST_SPFILE_PATH:'$RMAN_LATEST_SPFILE_PATH | $TEE -a $SOURCE_DBINFO
$ECHO 'RMAN_LATEST_SPFILE_DIR:'$RMAN_LATEST_SPFILE_DIR | $TEE -a $SOURCE_DBINFO
$ECHO 'RMAN_LATEST_SPFILE_SIZE(MB):'$RMAN_LATEST_SPFILE_SIZE_M | $TEE -a $SOURCE_DBINFO
$ECHO 'RMAN_LATEST_CTL_FILE_PATH:'$RMAN_LATEST_CTL_FILE_PATH | $TEE -a $SOURCE_DBINFO
$ECHO 'RMAN_LATEST_CTL_FILE_DIR:'$RMAN_LATEST_CTL_FILE_DIR | $TEE -a $SOURCE_DBINFO
$ECHO 'RMAN_LATEST_CTL_FILE_SIZE(MB):'$RMAN_LATEST_CTL_FILE_SIZE_M | $TEE -a $SOURCE_DBINFO
$ECHO 'LISTENER_FILE_PATH:'$LISTENER_FILE_PATH | $TEE -a $SOURCE_DBINFO
$ECHO 'BASE_ADMIN_DBNAME_DIR:'$BASE_ADMIN_DBNAME_DIR | $TEE -a $SOURCE_DBINFO
$ECHO 'PASSWORD_FILE_PATH:'$PASSWORD_FILE_PATH | $TEE -a $SOURCE_DBINFO
$ECHO 'ORACLE_BASE_PATH:'$ORACLE_BASE | $TEE -a $SOURCE_DBINFO
$ECHO 'ORACLE_HOME_PATH:'$ORACLE_HOME | $TEE -a $SOURCE_DBINFO
$ECHO 'ORACLE_SID:'$ORACLE_SID | $TEE -a $SOURCE_DBINFO
$ECHO 'ORACLE_SERVICE_NAME:'$ORACLE_SERVICE_NAME_VALUE | $TEE -a $SOURCE_DBINFO

}

###########################################################################

# +-----------------------------------------------------------------------+
# |                                                                       |
# | CALL FOLLOW TEN FUNCTIONS ORDINALLY:                                  |
# |                                                                       |
# | 1.QUERY_DBINFO                                                        |
# |                                                                       |
# | 2.QUERY_HOSTNAME_AND_DBVER                                            |
# |                                                                       |
# | 3.QUERY_ARCH_LOG                                                      |
# |                                                                       |
# | 4.QUERY_DB_FILE                                                       |
# |                                                                       |
# | 5.QUERY_BLOCK_CHANGE_TRACKING_FILE                                    |
# |                                                                       |
# | 6.QUERY_FAST_OR_FLASH_RECO_AREA                                       |
# |                                                                       |
# | 7.QUERY_RMAN_BACK                                                     |
# |                                                                       |
# | 8.QUERY_RMAN_LATEST_SPFILE                                            |
# |                                                                       |
# | 9.QUERY_RMAN_LATEST_CTL_FILE                                          |
# |                                                                       |
# | 10.QUERY_ORACLE_SERVICE_NAME                                          |
# |                                                                       |
# +-----------------------------------------------------------------------+

###########################################################################

query_dbinfo

query_hostname_and_dbver

query_arch_log

query_db_file

query_block_change_tracking_file

query_fast_or_flash_reco_area

query_rman_back

query_rman_latest_spfile

query_rman_latest_ctl_file

query_oracle_service_name

###########################################################################

# +-----------------------------------------------------------------------+
# |                                                                       |
# | PRINT LOG MESSAGES AFTER THIS SCRIPT EXECUTE AND WRITE A LOG FILE     |
# |                                                                       |
# +-----------------------------------------------------------------------+

###########################################################################

$ECHO "#################################################################" | $TEE -a $LOGFILE
$ECHO "#                                                               #" | $TEE -a $LOGFILE
$ECHO "#                            Attention                          #" | $TEE -a $LOGFILE
$ECHO "#                                                               #" | $TEE -a $LOGFILE
$ECHO -e "#################################################################\n" | $TEE -a $LOGFILE

###########################################################################

$ECHO -e "From local oracle database server,collect some basic information and print them to screen,and they are written to a log file at same time.\n" | $TEE -a $LOGFILE

$ECHO -e "This log file is located in [ \033[31;7m"$LOGFILE"\033[0m ].\n"

###########################################################################

# +-----------------------------------------------------------------------+
# |                                                                       |
# | CALL FUNCTION ABOUT 'PRINT_INFO_TO_FILE'                              |
# |                                                                       |
# +-----------------------------------------------------------------------+

###########################################################################

print_info_to_file

###########################################################################

$CAT $SOURCE_DBINFO >> $LOGFILE

$ECHO -e "\n#################################################################"

$ECHO -e "\nPlease remote copy a log file that is located in [ \033[31;7m"$SOURCE_DBINFO"\033[0m ] with scp command to remote host that restore and recover oracle database via local rman backupsets!!!\n"

###########################################################################
