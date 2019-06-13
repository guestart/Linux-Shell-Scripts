#!/bin/bash

# +-----------------------------------------------------------------------+
# |                                                                       |
# |                              Quanwen Zhao                             |
# |                                                                       |
# |                            guestart@163.com                           |
# |                                                                       |
# |                       quanwenzhao.wordpress.com                       |
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
# | File       : rman_restore_and_recover_to_target_oracle.sh             |
# |                                                                       |
# | CLASS      : LINUX Bourne-Again Shell Scripts                         |
# |                                                                       |
# | PURPOSE    : This bash script file used to restore and recover full   |
# |                                                                       |
# |              database to local with rman utility from rman backupset  |
# |                                                                       |
# |              of remote and used to do a regular backup recovery       | 
# |                                                                       |
# |              experiment, the premise is that there is a need to have  |
# |                                                                       |
# |              a set of oracle database software installed and same to  |
# |                                                                       |
# |              version of remote oracle database server, same to        |
# |                                                                       |
# |              operation system category and version.                   |
# |                                                                       |
# | PARAMETERS : None.                                                    |
# |                                                                       |
# | MODIFIED   : 03/10/2017 (mm/dd/yyyy)                                  |
# |                                                                       |
# | NOTE       : As with any code, ensure to use this script in a test    |
# |                                                                       |
# |              environment only.                                        |
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
export DF=`which df`
export ECHO=`which echo`
export GREP=`which grep`
export HOSTNAME=`which hostname`
export MKDIR=`which mkdir`
export SCP=`which scp`
export SCRIPT=`which script`
export SED=`which sed`
export SSH=`which ssh`
export TEE=`which tee`

###########################################################################

export LSNRCTL=$ORACLE_HOME/bin/lsnrctl
export RMAN=$ORACLE_HOME/bin/rman
export SQLPLUS=$ORACLE_HOME/bin/sqlplus

###########################################################################

export SOURCE_DBINFO='/tmp/source_oracle_dbinfo.log'
export LOGFILE="/tmp/rman_restore_and_recover_to_target_oracle_`$DATE +%F-%H-%M-%S`.log"

###########################################################################

export SOURCE_HOSTNAME=`$CAT $SOURCE_DBINFO | $AWK -F':' 'NR==1{print $2}'`
export SOURCE_OSNAME=`$CAT $SOURCE_DBINFO | $AWK -F':' 'NR==2{print $2}'`
export SOURCE_DBVERSION=`$CAT $SOURCE_DBINFO | $AWK -F':' 'NR==3{print $2}'`
export SOURCE_DBNAME=`$CAT $SOURCE_DBINFO | $AWK -F':' 'NR==4{print $2}'`
export SOURCE_DBID=`$CAT $SOURCE_DBINFO | $AWK -F':' 'NR==5{print $2}'`
export SOURCE_ARCH_LOG_PATH=`$CAT $SOURCE_DBINFO | $AWK -F':' 'NR==6{print $2}'`
export SOURCE_ARCH_LOG_TOTAL_SIZE_M=`$CAT $SOURCE_DBINFO | $AWK -F':' 'NR==7{print $2}'`
export SOURCE_DB_FILE_PATH=`$CAT $SOURCE_DBINFO | $AWK -F':' 'NR==8{print $2}'`
export SOURCE_DB_FILE_TOTAL_SIZE_M=`$CAT $SOURCE_DBINFO | $AWK -F':' 'NR==9{print $2}'`
export SOURCE_BLOCK_CHANGE_TRACKING_FILE_PATH=`$CAT $SOURCE_DBINFO | $AWK -F':' 'NR==10{print $2}'`
export SOURCE_BLOCK_CHANGE_TRACKING_FILE_DIR=`$CAT $SOURCE_DBINFO | $AWK -F':' 'NR==11{print $2}'`
export SOURCE_BLOCK_CHANGE_TRACKING_FILE_SIZE_M=`$CAT $SOURCE_DBINFO | $AWK -F':' 'NR==12{print $2}'`
export SOURCE_FAST_OR_FLASH_RECO_AREA_PATH=`$CAT $SOURCE_DBINFO | $AWK -F':' 'NR==13{print $2}'`
export SOURCE_RMAN_BACK_PATH=`$CAT $SOURCE_DBINFO | $AWK -F':' 'NR==14{print $2}'`
export SOURCE_RMAN_BACK_TOTAL_SIZE_M=`$CAT $SOURCE_DBINFO | $AWK -F':' 'NR==15{print $2}'`
export SOURCE_RMAN_LATEST_SPFILE_PATH=`$CAT $SOURCE_DBINFO | $AWK -F':' 'NR==16{print $2}'`
export SOURCE_RMAN_LATEST_SPFILE_DIR=`$CAT $SOURCE_DBINFO | $AWK -F':' 'NR==17{print $2}'`
export SOURCE_RMAN_LATEST_SPFILE_SIZE_M=`$CAT $SOURCE_DBINFO | $AWK -F':' 'NR==18{print $2}'`
export SOURCE_RMAN_LATEST_CTL_FILE_PATH=`$CAT $SOURCE_DBINFO | $AWK -F':' 'NR==19{print $2}'`
export SOURCE_RMAN_LATEST_CTL_FILE_DIR=`$CAT $SOURCE_DBINFO | $AWK -F':' 'NR==20{print $2}'`
export SOURCE_RMAN_LATEST_CTL_FILE_SIZE_M=`$CAT $SOURCE_DBINFO | $AWK -F':' 'NR==21{print $2}'`
export SOURCE_LISTENER_FILE_PATH=`$CAT $SOURCE_DBINFO | $AWK -F':' 'NR==22{print $2}'`
export SOURCE_BASE_ADMIN_DBNAME_DIR=`$CAT $SOURCE_DBINFO | $AWK -F':' 'NR==23{print $2}'`
export SOURCE_PASSWORD_FILE_PATH=`$CAT $SOURCE_DBINFO | $AWK -F':' 'NR==24{print $2}'`
export SOURCE_ORACLE_SID=`$CAT $SOURCE_DBINFO | $AWK -F':' 'NR==27{print $2}'`
export SOURCE_ORACLE_SERVICE_NAME=`$CAT $SOURCE_DBINFO | $AWK -F':' 'NR==28{print $2}'`

export SOURCE_REDO_LOG_SEQUENCE_CURRENT=
export SOURCE_REDO_LOG_SEQUENCE_PREVIEW=

###########################################################################

export TARGET_DBNAME=$SOURCE_DBNAME
export TARGET_DBID=$SOURCE_DBID
export TARGET_ARCH_LOG_PATH=$SOURCE_ARCH_LOG_PATH
export TARGET_ARCH_LOG_TOTAL_SIZE_M=$SOURCE_ARCH_LOG_TOTAL_SIZE_M
export TARGET_DB_FILE_PATH=$SOURCE_DB_FILE_PATH
export TARGET_DB_FILE_TOTAL_SIZE_M=$SOURCE_DB_FILE_TOTAL_SIZE_M
export TARGET_BLOCK_CHANGE_TRACKING_FILE=`$ECHO $SOURCE_BLOCK_CHANGE_TRACKING_FILE_PATH | $AWK -F'/' '{print $NF}'`
export TARGET_BLOCK_CHANGE_TRACKING_FILE_PATH=$SOURCE_BLOCK_CHANGE_TRACKING_FILE_PATH
export TARGET_BLOCK_CHANGE_TRACKING_FILE_DIR=$SOURCE_BLOCK_CHANGE_TRACKING_FILE_DIR
export TARGET_BLOCK_CHANGE_TRACKING_FILE_SIZE_M=$SOURCE_BLOCK_CHANGE_TRACKING_FILE_SIZE_M
export TARGET_FAST_OR_FLASH_RECO_AREA_PATH=$SOURCE_FAST_OR_FLASH_RECO_AREA_PATH
export TARGET_RMAN_BACK_PATH=$SOURCE_RMAN_BACK_PATH
export TARGET_RMAN_BACK_TOTAL_SIZE_M=$SOURCE_RMAN_BACK_TOTAL_SIZE_M
export TARGET_RMAN_LATEST_SPFILE_PATH=$SOURCE_RMAN_LATEST_SPFILE_PATH
export TARGET_RMAN_LATEST_SPFILE=`$ECHO $TARGET_RMAN_LATEST_SPFILE_PATH | $AWK -F'/' '{print $NF}'`
export TARGET_RMAN_LATEST_SPFILE_DIR=$SOURCE_RMAN_LATEST_SPFILE_DIR
export TARGET_RMAN_LATEST_SPFILE_SIZE_M=$SOURCE_RMAN_LATEST_SPFILE_SIZE_M
export TARGET_RMAN_LATEST_CTL_FILE_PATH=$SOURCE_RMAN_LATEST_CTL_FILE_PATH
export TARGET_RMAN_LATEST_CTL_FILE=`$ECHO $TARGET_RMAN_LATEST_CTL_FILE_PATH | $AWK -F'/' '{print $NF}'`
export TARGET_RMAN_LATEST_CTL_FILE_DIR=$SOURCE_RMAN_LATEST_CTL_FILE_DIR
export TARGET_RMAN_LATEST_CTL_FILE_SIZE_M=$SOURCE_RMAN_LATEST_CTL_FILE_SIZE_M
export TARGET_LISTENER_FILE=`$ECHO $SOURCE_LISTENER_FILE_PATH | $AWK -F'/' '{print $NF}'`
export TARGET_BASE_ADMIN_DBNAME_DIR=$SOURCE_BASE_ADMIN_DBNAME_DIR
export TARGET_PASSWORD_FILE=`$ECHO $SOURCE_PASSWORD_FILE_PATH | $AWK -F'/' '{print $NF}'`
export TARGET_ORACLE_SID=$SOURCE_ORACLE_SID

###########################################################################

export SOURCE_LISTENER_PORT=`$SSH $SOURCE_HOSTNAME $CAT $SOURCE_LISTENER_FILE_PATH | $GREP PORT | $AWK '{ print $NF }' | $AWK -F')' '{ print $1 }'`
export TARGET_LISTENER_PORT=1521

###########################################################################

export SOURCE_ADR_BASE=`$SSH $SOURCE_HOSTNAME $CAT $SOURCE_LISTENER_FILE_PATH | $GREP ADR_BASE | $AWK '{ print $NF }'`

###########################################################################

export TARGET_HOSTNAME=`$HOSTNAME`

###########################################################################

$ECHO "#################################################################" | $TEE -a $LOGFILE
$ECHO "#                                                               #" | $TEE -a $LOGFILE
$ECHO "#                            Attention                          #" | $TEE -a $LOGFILE
$ECHO "#                                                               #" | $TEE -a $LOGFILE
$ECHO -e "#################################################################\n" | $TEE -a $LOGFILE

###########################################################################

$ECHO -e "From now on,we are ready to restore and recover oracle database via remote rman backupsets on local host,all of processes are as follows and written to a log file.\n" | $TEE -a $LOGFILE

$ECHO -e "This log file is located in [ \033[31;7m"$LOGFILE"\033[0m ].\n"

$ECHO "#########################################################################" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO "# CREATE EIGHT NECESSARY DIRECTORY ON LOCAL ORACLE DATABASE SERVER      #" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO "# WITH MKDIR ABOUT BUILT-IN SHELL COMMAND ADDITIONAL PARAMETER '-p'.    #" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO "# 1. ORACLE ARCHIVE LOG DIRECTORY                                       #" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO "# 2. ORACLE DATABASE FILE DIRECTORY                                     #" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO "# 3. ORACLE BLOCK CHANGE TRACKING FILE DIRECTORY                        #" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO "# 4. ORACLE FAST OR FLASH RECO AREA DIRECTORY(INCLUDE SUBDIR OF DBNAME) #" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO "# 5. ORACLE RMAN BACKUP DIRECTORY                                       #" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO "# 6. LATEST RMAN BACKUP SPFILE DIRECTORY                                #" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO "# 7. LATEST RMAN BACKUP CONTROL FILE DIRECTORY                          #" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO "# 8. ORACLE DBNAME AND ITS SUBDIR(\$ORACLE_BASE/admin's SUBDIR)          #" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO -e "#########################################################################\n" | $TEE -a $LOGFILE

###########################################################################

for arch_log_path in $TARGET_ARCH_LOG_PATH
do
  $MKDIR -p $arch_log_path
  $ECHO -e 1. Create archive log directory \"$arch_log_path\" successfully."\n" | $TEE -a $LOGFILE
done

###########################################################################

for db_file_path in $TARGET_DB_FILE_PATH
do
  $MKDIR -p $db_file_path
  $ECHO -e 2. Create database file directory \"$db_file_path\" successfully."\n" | $TEE -a $LOGFILE
done

###########################################################################

if [ ! -z $TARGET_BLOCK_CHANGE_TRACKING_FILE_PATH ]; then
  $MKDIR -p $TARGET_BLOCK_CHANGE_TRACKING_FILE_DIR
  $ECHO -e 3. Create block change tracking file directory \"$TARGET_BLOCK_CHANGE_TRACKING_FILE_DIR\" successfully."\n" | $TEE -a $LOGFILE
else
  $ECHO -e 3. Oracle database server don\'t configure block change tracking file."\n" | $TEE -a $LOGFILE  
fi

###########################################################################

if [ ! -z $TARGET_FAST_OR_FLASH_RECO_AREA_PATH ]; then
  $MKDIR -p $TARGET_FAST_OR_FLASH_RECO_AREA_PATH/$TARGET_DBNAME
  $ECHO -e 4. Create fast or flash recovery area directory \"$TARGET_FAST_OR_FLASH_RECO_AREA_PATH\" and its subdir \"$TARGET_DBNAME\" successfully."\n" | $TEE -a $LOGFILE
  TARGET_DBNAME=`$ECHO $TARGET_DBNAME | $AWK '{ print toupper($0)}'`
  $MKDIR -p $TARGET_FAST_OR_FLASH_RECO_AREA_PATH/$TARGET_DBNAME
  $ECHO -e 4. Create fast or flash recovery area directory \"$TARGET_FAST_OR_FLASH_RECO_AREA_PATH\" and its subdir \"$TARGET_DBNAME\" successfully."\n" | $TEE -a $LOGFILE
else
  $ECHO -e 4. Oracle database server don\'t configure fast or flash recovery area."\n" | $TEE -a $LOGFILE
fi

TARGET_DBNAME=`$ECHO $TARGET_DBNAME | $AWK '{ print tolower($0)}'`

###########################################################################

for rman_back_path in $TARGET_RMAN_BACK_PATH
do
  $MKDIR -p $rman_back_path
  $ECHO -e 5. Create rman backup directory \"$rman_back_path\" successfully."\n" | $TEE -a $LOGFILE
done

###########################################################################

if [ ! -d $TARGET_RMAN_LATEST_SPFILE_DIR ]; then
  $MKDIR -p $TARGET_RMAN_LATEST_SPFILE_DIR
fi

$ECHO -e 6. Create latest rman backup spfile directory \"$TARGET_RMAN_LATEST_SPFILE_DIR\" successfully."\n" | $TEE -a $LOGFILE

###########################################################################

if [ ! -d $TARGET_RMAN_LATEST_CTL_FILE_DIR ]; then
  $MKDIR -p $TARGET_RMAN_LATEST_CTL_FILE_DIR
fi

$ECHO -e 7. Create latest rman backup control file directory \"$TARGET_RMAN_LATEST_CTL_FILE_DIR\" successfully."\n" | $TEE -a $LOGFILE

###########################################################################

$MKDIR -p $ORACLE_BASE/admin/$TARGET_DBNAME
$ECHO -e 8. Create dbname directory \"$ORACLE_BASE/admin/$TARGET_DBNAME\" successfully."\n" | $TEE -a $LOGFILE

for dbname_subdir in $TARGET_BASE_ADMIN_DBNAME_DIR
do
  $MKDIR -p $ORACLE_BASE/admin/$TARGET_DBNAME/$dbname_subdir
  $ECHO -e "   "Create dbname directory\'s subdir \"$dbname_subdir\" successfully."\n" | $TEE -a $LOGFILE
done

###########################################################################

$ECHO "#########################################################################" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO "# SCP PASSWORD FILE AND LISTENER FILE TO LOCAL ORACLE DATABASE SERVER   #" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO -e "#########################################################################\n" | $TEE -a $LOGFILE

###########################################################################

$SCRIPT -a $LOGFILE -c "$SCP -p $SOURCE_HOSTNAME:$SOURCE_LISTENER_FILE_PATH $ORACLE_HOME/network/admin" > /dev/null

$ECHO -e "\n"Remote copy listener file \"$TARGET_LISTENER_FILE\" with scp command to local successfully."\n" | $TEE -a $LOGFILE

$SCRIPT -a $LOGFILE -c "$SCP -p $SOURCE_HOSTNAME:$SOURCE_PASSWORD_FILE_PATH $ORACLE_HOME/dbs" > /dev/null

$ECHO -e "\n"Remote copy password file \"$TARGET_PASSWORD_FILE\" with scp command to local successfully."\n" | $TEE -a $LOGFILE

###########################################################################

$ECHO "#########################################################################" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO "# CHANGE VALUE OF \"HOST\" IN FILE \"listener.ora\" TO HOSTNAME OF LOCAL    #" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO -e "#########################################################################\n" | $TEE -a $LOGFILE

###########################################################################

$SED -i "s/$SOURCE_HOSTNAME/$TARGET_HOSTNAME/g" $ORACLE_HOME/network/admin/$TARGET_LISTENER_FILE

$ECHO -e Change value of \"HOST\" in file \"$TARGET_LISTENER_FILE\" to hostname of local successfully."\n" | $TEE -a $LOGFILE

###########################################################################

$ECHO "#########################################################################" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO "# SCP LATEST RMAN BACKUP SPFILE OF SOURCE ORACLE DATABASE TO LOCAL      #" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO -e "#########################################################################\n" | $TEE -a $LOGFILE

###########################################################################

$SCRIPT -a $LOGFILE -c "$SCP -p $SOURCE_HOSTNAME:$SOURCE_RMAN_LATEST_SPFILE_PATH $TARGET_RMAN_LATEST_SPFILE_DIR" > /dev/null

$ECHO -e "\n"Remote copy latest rman backup spfile \"$TARGET_RMAN_LATEST_SPFILE\" to local successfully."\n" | $TEE -a $LOGFILE

###########################################################################

$ECHO "#########################################################################" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO "# SCP LATEST RMAN BACKUP CTLFILE OF SOURCE ORACLE DATABASE TO LOCAL     #" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO -e "#########################################################################\n" | $TEE -a $LOGFILE

###########################################################################

$SCRIPT -a $LOGFILE -c "$SCP -p $SOURCE_HOSTNAME:$SOURCE_RMAN_LATEST_CTL_FILE_PATH $TARGET_RMAN_LATEST_CTL_FILE_DIR" > /dev/null

$ECHO -e "\n"Remote copy latest rman backup control file \"$TARGET_RMAN_LATEST_CTL_FILE\" to local successfully."\n" | $TEE -a $LOGFILE

###########################################################################

$ECHO "#########################################################################" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO "# SCP BLOCK CHANGE TRACKING FILE OF SOURCE ORACLE DATABASE TO LOCAL     #" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO -e "#########################################################################\n" | $TEE -a $LOGFILE

###########################################################################

if [ ! -z $TARGET_BLOCK_CHANGE_TRACKING_FILE_PATH ]; then
  $SCRIPT -a $LOGFILE -c "$SCP -p $SOURCE_HOSTNAME:$SOURCE_BLOCK_CHANGE_TRACKING_FILE_PATH $TARGET_BLOCK_CHANGE_TRACKING_FILE_DIR" > /dev/null
  $ECHO -e "\n"Remote copy block change tracking file \"$TARGET_BLOCK_CHANGE_TRACKING_FILE\" to local successfully."\n" | $TEE -a $LOGFILE
fi

###########################################################################

$ECHO "#########################################################################" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO "# SCP RMAN BACKUPSETS OF SOURCE ORACLE DATABASE TO LOCAL HOST           #" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO -e "#########################################################################\n" | $TEE -a $LOGFILE

###########################################################################

for rman_back_path in $TARGET_RMAN_BACK_PATH
do
  $SCRIPT -a $LOGFILE -c "$SCP -p $SOURCE_HOSTNAME:$rman_back_path/* $rman_back_path"
done

$ECHO -e "\n"Remote copy all of valid rman backupsets to local successfully."\n" | $TEE -a $LOGFILE 

###########################################################################

$ECHO "#########################################################################" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO "# RESTORE SPFILE,CTLFILE AND DB FILES WITH RMAN BACKUPSETS ORDINALLY    #" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO -e "#########################################################################" | $TEE -a $LOGFILE

###########################################################################

export ORACLE_SID=$TARGET_ORACLE_SID

$RMAN target / nocatalog log $LOGFILE append <<EOF
set dbid=$TARGET_DBID;
startup nomount;
restore spfile from '$TARGET_RMAN_LATEST_SPFILE_PATH';
shutdown immediate;
startup nomount;
restore controlfile from '$TARGET_RMAN_LATEST_CTL_FILE_PATH';
alter database mount;
run
{
allocate channel d1 type disk maxpiecesize 16g;
allocate channel d2 type disk maxpiecesize 16g;
allocate channel d3 type disk maxpiecesize 16g;
allocate channel d4 type disk maxpiecesize 16g;
restore database;
release channel d4;
release channel d3;
release channel d2;
release channel d1;
}
exit;
EOF

###########################################################################

$ECHO -e "\n#########################################################################" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO "# PERFORM TWO STEPS AS FOLLOWS:                                         #" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO "# 1. QUERY GROUP NUMS OF REDO LOG OF SOURCE ORACLE DATABASE             #" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO "# 2. SWITCH CURRENT REDO LOG OF SOURCE ORACLE DATABASE TO ARCHIVE       #" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO -e "#########################################################################\n" | $TEE -a $LOGFILE

###########################################################################

$SQLPLUS -S system/sys@$SOURCE_HOSTNAME:$SOURCE_LISTENER_PORT/$SOURCE_ORACLE_SERVICE_NAME << EOF
set echo off feedback off heading off underline off;
set serveroutput on;
declare
nums number;
str_exec_sql varchar2(512);
begin
select count(group#) into nums from v\$log;
str_exec_sql :='alter system archive log current';
for num in 1 .. nums
loop
  execute immediate str_exec_sql;
end loop;
end;
/
exit;
EOF

$ECHO -e Switch all online redo log to be archive log successfully."\n" | $TEE -a $LOGFILE

###########################################################################
  
$ECHO "#########################################################################" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO "# SCP ALL ARCHIVE LOG FILES OF SOURCE ORACLE DATABASE TO LOCAL HOST     #" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO -e "#########################################################################\n" | $TEE -a $LOGFILE

###########################################################################

for arch_log_path in $TARGET_ARCH_LOG_PATH
do
  $SCRIPT -a $LOGFILE -c "$SCP -p $SOURCE_HOSTNAME:$arch_log_path/* $arch_log_path"
done

$ECHO -e "\n"Remote copy all archive log files to local successfully."\n" | $TEE -a $LOGFILE

###########################################################################

$ECHO "#########################################################################" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO "# RECOVER DATABASE WITH RMAN INCREMENTAL BACKUPSETS AND ARCHIVE LOG     #" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO -e "#########################################################################" | $TEE -a $LOGFILE

###########################################################################

SOURCE_REDO_LOG_SEQUENCE_CURRENT=`$SQLPLUS -S system/sys@$SOURCE_HOSTNAME:$SOURCE_LISTENER_PORT/$SOURCE_ORACLE_SERVICE_NAME << EOF
set echo off feedback off heading off underline off;
select sequence# from v\\$log where status='CURRENT';
exit;
EOF`

SOURCE_REDO_LOG_SEQUENCE_PREVIEW=$((SOURCE_REDO_LOG_SEQUENCE_CURRENT-1))

$RMAN target / nocatalog log $LOGFILE append <<EOF
run
{
allocate channel d1 type disk maxpiecesize 16g;
allocate channel d2 type disk maxpiecesize 16g;
allocate channel d3 type disk maxpiecesize 16g;
allocate channel d4 type disk maxpiecesize 16g;
recover database until sequence $SOURCE_REDO_LOG_SEQUENCE_PREVIEW;
release channel d4;
release channel d3;
release channel d2;
release channel d1;
}
exit;
EOF

###########################################################################

$ECHO -e "\n#########################################################################" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO "# OPEN LOCAL'S ORACLE DATABASE WITH 'RESETLOGS'                         #" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO -e "#########################################################################\n" | $TEE -a $LOGFILE

###########################################################################

$SQLPLUS -S / as sysdba << EOF
alter database open resetlogs;
exit;
EOF

$ECHO -e Open oracle database with \'resetlogs\' successfully."\n" | $TEE -a $LOGFILE

###########################################################################

$ECHO "#########################################################################" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO "# START LOCAL ORACLE DATABASE SERVER'S LISTENER                         #" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO -e "#########################################################################\n" | $TEE -a $LOGFILE

###########################################################################

#$LSNRCTL START

$ECHO -e Start listener successfully."\n" | $TEE -a $LOGFILE

###########################################################################

$ECHO "#########################################################################" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO "# APPEND '\$ORACLE_SID:\$ORACLE_HOME:N' TO FILE '/etc/oratab'             #" | $TEE -a $LOGFILE
$ECHO "#                                                                       #" | $TEE -a $LOGFILE
$ECHO -e "#########################################################################\n" | $TEE -a $LOGFILE

###########################################################################

$ECHO $TARGET_DBNAME:$ORACLE_HOME:N >> /etc/oratab

$ECHO -e Append \"\$ORACLE_SID:\$ORACLE_HOME:N\" to file \"/etc/oratab\" successfully."\n" | $TEE -a $LOGFILE

###########################################################################
