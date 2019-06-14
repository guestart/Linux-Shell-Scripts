#!/bin/bash

# The crontab setting on oracle user of linux server is as follows:

# 30 22 * * * ~/rman_backup/rman_backup.sh >>/dev/null 2>&1

# +------------------------------------------------------------------------+
# |                                                                        |
# |                              Quanwen Zhao                              |
# |                                                                        |
# |                            guestart@163.com                            |
# |                                                                        |
# |                        quanwenzhao.wordpress.com                       |
# |                                                                        |
# |------------------------------------------------------------------------|
# |                                                                        |
# |          Copyright (c) 2016 Quanwen Zhao. All rights reserved.         |
# |                                                                        |
# |------------------------------------------------------------------------|
# |                                                                        |
# | File Name    : ~/rman_backup/rman_backup.sh                            |
# |                                                                        |
# | Author       : Quanwen Zhao                                            |
# |                                                                        |
# | Description  : This bash script file used to backup one week via rman  |
# |                                                                        |
# |                utility on Oracle Database Server.                      |
# |                                                                        |
# | Call Syntax  : . ~/rman_backup/rman_backup.sh                          |
# |                                                                        |
# |                or                                                      |
# |                                                                        |
# |                sh ~/rman_backup/rman_backup.sh                         |
# |                                                                        |
# | Last Modified: 11/10/2016 (dd/mm/yyyy)                                 |
# |                                                                        |
# +------------------------------------------------------------------------+

# +------------------------------------------------------------------------+
# |                                                                        |
# | Export environment variable of oracle user                             |
# |                                                                        |
# +------------------------------------------------------------------------+

source ~/.bash_profile;

# +------------------------------------------------------------------------+
# |                                                                        |
# | Define some shell variables                                            |
# |                                                                        |
# +------------------------------------------------------------------------+

export BACK_PATH=~/rman_backup

export BACK_LOG=~/rman_backup/log

export DATE=`which date`

export RMAN_BIN=$ORACLE_HOME/bin

export FIND=`which find`

export DATE_W=`$DATE +%u`

# +------------------------------------------------------------------------+
# |                                                                        |
# | Create a directory of current date                                     |
# |                                                                        |
# +------------------------------------------------------------------------+

if [ ! -d "$BACK_PATH/`$DATE +%m-%d`" ]; then

  mkdir -p $BACK_PATH/`$DATE +%m-%d`

fi

# +------------------------------------------------------------------------+
# |                                                                        |
# | One week rman backup of incremental level 0 on Friday 22:30, and       |
# |                                                                        |
# | incremental level 1 on Satruday ~ Thursday 22:30                       |
# |                                                                        |
# +------------------------------------------------------------------------+

case $DATE_W in

5)

$RMAN_BIN/rman nocatalog log $BACK_LOG/level0_`$DATE +%Y-%m-%d`.log <<EOF
connect target /
run {
allocate channel d1 type disk maxpiecesize 16g;
allocate channel d2 type disk maxpiecesize 16g;
allocate channel d3 type disk maxpiecesize 16g;
allocate channel d4 type disk maxpiecesize 16g;
backup incremental level 0 database format '$BACK_PATH/`$DATE +%m-%d`/DATA_level0_%d_%s_%p_%u.bak' include current controlfile
plus archivelog format '$BACK_PATH/`$DATE +%m-%d`/archivelog_%d_%s_%p_%u.bak' delete all input;
release channel d4;
release channel d3;
release channel d2;
release channel d1;
}
crosscheck backup;
exit;
EOF

# +------------------------------------------------------------------------+
# |                                                                        |
# | Maintenace rman backup of last week on Friday                          |
# |                                                                        |
# +------------------------------------------------------------------------+

$RMAN_BIN/rman nocatalog log $BACK_LOG/maintenance_`$DATE +%Y-%m-%d`.log <<EOF
connect target /
report obsolete;
delete noprompt expired backup;
allocate channel for maintenance type disk;
delete noprompt obsolete device type disk;
exit;
EOF

# +------------------------------------------------------------------------+
# |                                                                        |
# | Remove empty directories after obsolete backup deleted on Friday       |
# |                                                                        |
# +------------------------------------------------------------------------+

$FIND $BACK_PATH -type d -empty -exec rmdir {} \;
;;

1|2|3|4|6|7)

$RMAN_BIN/rman nocatalog log $BACK_LOG/level1_`$DATE +%Y-%m-%d`.log <<EOF
connect target /
run {
allocate channel d1 type disk maxpiecesize 8g;
allocate channel d2 type disk maxpiecesize 8g;
backup incremental level 1 database format '$BACK_PATH/`$DATE +%m-%d`/level1_%d_%s_%p_%u.bak' include current controlfile
plus archivelog format '$BACK_PATH/`DATE +%m-%d`/archivelog_%d_%s_%p_%u.bak' delete all input;
release channel d2;
release channel d1;
}
crosscheck backup;
exit;
EOF
;;
esac
