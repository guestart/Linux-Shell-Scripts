# Author:        Quanwen Zhao
# Last Updated:  Jul 11, 2019

#!/bin/bash

# The crontab setting on oracle user of linux server is as follows:

# 00 18 * * * ~/rman_backup/exp_test_and_del_yesterday.sh >>/dev/null 2>&1

##################################################
# Export environment variable of oracle user

source ~/.bash_profile;

export ORACLE_BASE=/u01/app/oracle

export ORACLE_HOME=$ORACLE_BASE/product/11.2.0/db_1

export NLS_LANG=AMERICAN_AMERICA.AL32UTF8

export EXP=$ORACLE_HOME/bin/exp

##################################################
# Define some shell variables

export ECHO=`which echo`

export RM=`which rm`

export DATE=`which date`

export CURRENT_DATE=`$DATE +%Y%m%d%H%M%S`

###########################################################################
# Export and generate dmp and log file of Oracle user about test
# via exp command
# adding four number of new parameters - "direct, buffer, feedback and recordlength"

$EXP test/xxxx@test file=~/rman_backup/exp_test_${CURRENT_DATE}.dmp log=~/rman_backup/exp_test_${CURRENT_DATE}.log owner=test direct=y buffer=10240000 feedback=10000 recordlength=65535

##########################################################

if [ `$ECHO $?` -eq 0 ]; then

  # Switch current directory to exp_dir

  cd ~/rman_backup

  # Remove dmp and log file yesterday,only reserve today's

  $RM -rf test_`$DATE -d'yesterday' +%Y%m%d`*

fi
