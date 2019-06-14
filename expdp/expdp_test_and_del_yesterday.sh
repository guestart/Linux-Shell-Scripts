#!/bin/bash

# The crontab setting on oracle user of linux server is as follows:

# 00 04 * * * ~/rman_backup/expdp_test_and_del_yesterday.sh >>/dev/null 2>&1

##################################################
# Export environment variable of oracle user

source ~/.bash_profile;

export NLS_LANG=AMERICAN_AMERICA.AL32UTF8

export EXPDP=$ORACLE_HOME/bin/expdp

##################################################
# Define some shell variables

export ECHO=`which echo`

export RM=`which rm`

export DATE=`which date`

export CURRENT_DATE=`$DATE +%Y%m%d%H%M%S`

###############################################################################
# Export and generate dmp and log file of Oracle user about test
# via expdp command

$EXPDP test/xxxx@test schemas=test directory=expdp parallel=3 dumpfile=expdp_test_${CURRENT_DATE}_%U.dmp filesize=50G logfile=expdp_test_${CURRENT_DATE}.log statistics=none indexes=y

##########################################################

if [ `$ECHO $?` -eq 0 ]; then

  # Switch current directory to expdp

  cd ~/rman_backup/expdp

  # Remove dmp and log file yesterday,only reserve today's

  $RM -rf expdp_test_`$DATE -d'yesterday' +%Y%m%d`*.dmp

fi
