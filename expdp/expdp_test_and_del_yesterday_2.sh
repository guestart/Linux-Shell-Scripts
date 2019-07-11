# Author:        Quanwen Zhao
# Last Updated:  Jul 11, 2019

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

# $EXPDP test/xxxx@test schemas=test directory=expdp parallel=3 dumpfile=expdp_test_${CURRENT_DATE}_%U.dmp filesize=50G logfile=expdp_test_${CURRENT_DATE}.log statistics=none
# If using the above expdp command as you can see the below export message warnings.

# Export: Release 11.2.0.4.0 - Production on Fri Jul 5 14:28:51 2019

# Copyright (c) 1982, 2011, Oracle and/or its affiliates.  All rights reserved.

# Connected to: Oracle Database 11g Enterprise Edition Release 11.2.0.4.0 - 64bit Production
# With the Partitioning, Oracle Label Security, OLAP, Data Mining,
# Oracle Database Vault and Real Application Testing options
# Legacy Mode Active due to the following parameters:
# Legacy Mode Parameter: "statistics=none" Location: Command Line, ignored.  <<==
# Legacy Mode has set reuse_dumpfiles=true parameter.
# ......

# Use the following right expdp command to exclude both statistics, because of the previous expdp command still export the statistics info.
# $EXPDP test/xxxx@test schemas=test directory=expdp parallel=3 dumpfile=expdp_test_${CURRENT_DATE}_%U.dmp filesize=50G logfile=expdp_test_${CURRENT_DATE}.log exclude=statistics

# Adding a new parameter compression.
$EXPDP test/xxxx@test schemas=test directory=expdp parallel=3 dumpfile=expdp_test_${CURRENT_DATE}_%U.dmp filesize=50G logfile=expdp_test_${CURRENT_DATE}.log exclude=statistics compression=all

##########################################################

if [ `$ECHO $?` -eq 0 ]; then

  # Switch current directory to expdp

  cd ~/rman_backup/expdp

  # Remove dmp and log file yesterday,only reserve today's

  $RM -rf expdp_test_`$DATE -d'yesterday' +%Y%m%d`*.dmp

fi
