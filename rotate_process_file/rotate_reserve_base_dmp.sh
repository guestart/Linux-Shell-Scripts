# [oracle@huba-master-02 ~]$ df -h
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/sda2       212G  5.6G  195G   3% /
# tmpfs            63G   80K   63G   1% /dev/shm
# /dev/sda1       190M   32M  149M  18% /boot
# /dev/sdb1        47T   42T  2.5T  95% /u01/oradata <<==

# [oracle@huba-master-02 ~]$ cd /u01/oradata
# [oracle@huba-master-02 ~]$ 
# [oracle@huba-master-02 oradata]$ ls -lrth *
# total 42T
# -rw-r-----. 1 oracle oracle 99G Aug 09 2018 xxxx_base_20180809040001_01.dmp
# -rw-r-----. 1 oracle oracle 30G Aug 09 2018 xxxx_base_20180809040001_02.dmp
# -rw-r-----. 1 oracle oracle 31G Aug 09 2018 xxxx_base_20180809040001_03.dmp
# -rw-r--r--. 1 oracle oracle 15K Aug 09 2018 xxxx_base_20180809040001.log
# -rw-r-----. 1 oracle oracle 99G Aug 10 2018 xxxx_base_20180810040001_01.dmp
# -rw-r-----. 1 oracle oracle 31G Aug 10 2018 xxxx_base_20180810040001_02.dmp
# -rw-r-----. 1 oracle oracle 31G Aug 10 2018 xxxx_base_20180810040001_03.dmp
# -rw-r--r--. 1 oracle oracle 15K Aug 10 2018 xxxx_base_20180810040001.log
# ......
# -rw-r--r--. 1 oracle oracle    15K Jun 12 04:36 xxxx_base_20190612040001.log
# -rw-r-----. 1 oracle oracle   7.9G Jun 12 04:36 xxxx_base_20190612040001_03.dmp
# -rw-r-----. 1 oracle oracle    19G Jun 12 04:36 xxxx_base_20190612040001_02.dmp
# -rw-r-----. 1 oracle oracle    21G Jun 12 04:36 xxxx_base_20190612040001_01.dmp
# -rw-r--r--. 1 oracle oracle    15K Jun 13 04:34 xxxx_base_20190613040001.log
# -rw-r-----. 1 oracle oracle   8.0G Jun 13 04:34 xxxx_base_20190613040001_03.dmp
# -rw-r-----. 1 oracle oracle    22G Jun 13 04:34 xxxx_base_20190613040001_02.dmp
# -rw-r-----. 1 oracle oracle    19G Jun 13 04:34 xxxx_base_20190613040001_01.dmp

# [oracle@huba-master-02 ~]$ crontab -l
# 00 05 * * 5 ~/rotate_reserve_base_dmp.sh

#!/bin/bash

# +-------------------------------------------------------------------------+
# |                                                                         |
# | File Name    : rotate_reserve_base_dmp.sh                               |
# |                                                                         |
# | Author       : Quanwen Zhao                                             |
# |                                                                         |
# | Description  : This bash script file used to periodically remove some   |
# |                                                                         |
# |                earliest so far 7 number of "xxxx_base_xxxx.dmp" file,   |
# |                                                                         |
# |                which located in directory "/u01/oradata" on oracle user |
# |                                                                         |
# |                for keeping sufficient disk space in reserve.            |
# |                                                                         |
# | Call Syntax  : . rotate_reserve_base_dmp.sh                             |
# |                                                                         |
# |                or                                                       |
# |                                                                         |
# |                sh ~/rotate_reserve_base_dmp.sh                          |
# |                                                                         |
# | Last Modified: 06/12/2019 (mm/dd/yyyy)                                  |
# |                                                                         |
# | Updated:       06/13/2019 (mm/dd/yyyy)                                  |
# |                                                                         |
# +-------------------------------------------------------------------------+

# +--------------------------------------------+
# |                                            |
# | EXPORT ENVIRONMENT VARIABLE OF ORACLE USER |
# |                                            |
# +--------------------------------------------+

source ~/.bash_profile;

# +-------------------------------------------------------------------------+
# |                                                                         |
# | DEFINE SOME SHELL STRING VARIABLES ON ABSOLUTE PATH OF EXTERNAL COMMAND |
# |                                                                         |
# | AND DIRECTORY                                                           |
# |                                                                         |
# +-------------------------------------------------------------------------+

export AWK=`which awk`

export DF=`which df`

export EXPR=`which expr`

export GREP=`which grep`

export HEAD=`which head`

export LS=`which ls`

export RM=`which rm`

export SORT=`which sort`

# +----------------------------------------------------------+
# |                                                          |
# | CALCULATE THE AVAILABLE SIZE OF DIRECTORY "/u01/oradata" |
# |                                                          |
# +----------------------------------------------------------+

# export AVAI_SIZE=`$DF | $GREP "/u01/oradata" | $AWK '{print $(NF-2)}'`

# +--------------------------------------------------------+
# |                                                        |
# | CALCULATE THE USED PERCENT OF DIRECTORY "/u01/oradata" |
# |                                                        |
# +--------------------------------------------------------+

export USED_PERCENT=`$DF -h | $GREP "/u01/oradata" | $AWK '{print $(NF-1)}' | $AWK -F '%' '{print $1}'`

# +------------------------------------------------+
# |                                                |
# | CHANGE THE CURRENT DIRECTORY TO "/u01/oradata" |
# |                                                |
# +------------------------------------------------+

cd /u01/oradata

# +--------------------------------------------------------------------------+
# |                                                                          |
# | IF THE AVAILABLE SIZE OF "/u01/oradata" IS LESS THAN 2.0 TB, THEN REMOVE |
# |                                                                          |
# | SOME EARLIEST SO FAR 7 number of "xxxx_base_xxxx.dmp" FILE, OTHERWISE DO |
# |                                                                          |
# | NOTHING.                                                                 |
# |                                                                          |
# +--------------------------------------------------------------------------+

export EARLIEST_SO_FAR_7_NUMBER_DATE_LIST=`$LS -lrth . | $GREP log | $AWK '{print $NF}' | $AWK -F '.' '{print $1}' | $AWK -F '_' '{print $NF}' | $SORT -n | $HEAD -7`

#for i in ${EARLIEST_SO_FAR_7_NUMBER_DATE_LIST}
#do
#  if [ `$EXPR $AVAI_SIZE / 1024 / 1024` -lt 2048 ]; then
#    $RM -rf expdp_szd_base_v2_$i*
#  fi
#done

# +--------------------------------------------------------------------------+
# |                                                                          |
# | IF THE USED PERCENT OF "/u01/oradata" IS GREATER THAN "95%", THEN REMOVE |
# |                                                                          |
# | SOME EARLIEST SO FAR 7 number of "xxxx_base_xxxx.dmp" FILE, OTHERWISE DO |
# |                                                                          |
# | NOTHING.                                                                 |
# |                                                                          |
# +--------------------------------------------------------------------------+

for i in ${EARLIEST_SO_FAR_7_NUMBER_DATE_LIST}
do
  if [ $USED_PERCENT -gt 95 ]; then
    $RM -rf expdp_szd_base_v2_$i*
  fi
done
