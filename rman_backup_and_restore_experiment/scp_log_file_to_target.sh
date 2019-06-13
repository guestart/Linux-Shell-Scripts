#!/bin/bash

# +-----------------------------------------------------------------------+
# |                              Quanwen Zhao                             |
# |                            guestart@163.com                           |
# |                        quanwenzhao.wordpress.com                      |
# |-----------------------------------------------------------------------|
# |      Copyright (c) 2016-2017 Quanwen Zhao. All rights reserved.       |
# |-----------------------------------------------------------------------|
# | DATABASE   : Oracle                                                   |
# | OS ENV     : Linux                                                    |
# | File       : scp_log_file_to_target.sh                                |
# | CLASS      : LINUX Bourne-Again Shell Scripts                         |
# | PURPOSE    : This bash script file used to remote copy a local log    |
# |              file to remote host.                                     |
# |                                                                       |
# | PARAMETERS : None.                                                    |
# |                                                                       |
# | MODIFIED   : 03/10/2017 (mm/dd/yyyy)                                  |
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
# | GLOBAL VARIABLES ABOUT STRINGS AND BACKTICK EXECUTION RESULT OF SHELL |
# +-----------------------------------------------------------------------+

export SCP=`which scp`

export LOCAL_LOGFILE='/tmp/source_oracle_dbinfo.log'

# Define Remote Host, For example, REMOTE_HOST='orcl1', According to your situation to set.
export REMOTE_HOST='orcl13'

# +-----------------------------------------------------------------------+
# | USE SCP COMMAND TO COPY A LOCAL LOG FILE TO TARGET HOST               |
# +-----------------------------------------------------------------------+

$SCP $LOCAL_LOGFILE oracle@$REMOTE_HOST:/tmp
