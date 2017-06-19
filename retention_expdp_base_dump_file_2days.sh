#!/bin/bash

# +-----------------------------------------------------------------------+
# |                              Quanwen Zhao                             |
# |                            guestart@163.com                           |
# |                        guestart.blog.51cto.com                        |
# |-----------------------------------------------------------------------|
# |      Copyright (c) 2016-2017 Quanwen Zhao. All rights reserved.       |
# |-----------------------------------------------------------------------|
# | DATABASE   : Oracle                                                   |
# | OS ENV     : Linux                                                    |
# | File       : retention_expdp_base_dump_file_2days.sh                  |
# | CLASS      : LINUX Bourne-Again Shell Scripts                         |
# | PURPOSE    : This bash script file used to delete dmp file of expdp   |
# |              all of data about user "szd_base_v2" in oracle database  |
# |              2 days before on every saturday at 05:00 before dawn.    |
# | PARAMETERS : None.                                                    |
# | MODIFIED   : 05/22/2017 (mm/dd/yyyy)                                  |
# | NOTE       : As with any code,ensure to test this script in a         |
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

export DATE=`which date`
export ECHO=`which echo`
export GREP=`which grep`
export LS=`which ls`
export MKDIR=`which mkdir`
export RM=`which rm`
export TEE=`which tee`

# +-----------------------------------------------------------------------+
# | SWITCH CURRENT DIRECTORY TO EXPDP DIRECTORY OF ORACLE USER WITH CD    |
# +-----------------------------------------------------------------------+

cd /u01/oradata/rman_backup/expdp

# +-----------------------------------------------------------------------+
# | GLOBAL VARIABLES ABOUT THE BACKTICK EXECUTION RESULT OF THE SHELL     |
# +-----------------------------------------------------------------------+

export TODAY=`$DATE +%Y%m%d`

export YESTERDAY=`$DATE +%Y%m%d -d yesterday`

export OBSOLETE_EXPDP_BASE_DMP=`$LS expdp_szd_base_v2_*.dmp expdp_szd_base_v2_*.log | $GREP -v $TODAY | $GREP -v $YESTERDAY`

export OBSOLETE_EXPDP_BASE_DMP_FILE=

# +-----------------------------------------------------------------------+
# | GLOBAL VARIABLE ABOUT STRINGS                                         |
# +-----------------------------------------------------------------------+

export LOG_FILE_PATH='/u01/oradata01/rman_backup/del_expdp_base_log'

export LOG_FILE=$LOG_FILE_PATH/del_expdp_base_`$DATE +%Y%m%d%H%M%S`.log

# +-----------------------------------------------------------------------+
# | IF NOT EXISTS,CREATE DIRECTORY OF GLOBAL VARIABLE 'LOG_FILE_PATH'     |
# +-----------------------------------------------------------------------+

if [ ! -d $LOG_FILE_PATH ]; then
  $MKDIR -p $LOG_FILE_PATH
fi

# +-----------------------------------------------------------------------+
# | DELETE ALL OF OBSOLETE EXPDP DMP FILES ( EXCLUDE BE GENERATED TODAY   |
# | AT 04:00 AND YESTERDAY'S ) ON EVERYDAY AT 05:00 BEFORE DAWN.          |
# +-----------------------------------------------------------------------+

for OBSOLETE_EXPDP_BASE_DMP_FILE in $OBSOLETE_EXPDP_BASE_DMP
do
  $ECHO "$RM -rf $OBSOLETE_EXPDP_BASE_DMP_FILE" | $TEE -a $LOG_FILE
  $RM -rf $OBSOLETE_EXPDP_BASE_DMP_FILE
done
