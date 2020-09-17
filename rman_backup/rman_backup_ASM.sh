# RMAN Configuration

# CONFIGURE RETENTION POLICY TO REDUNDANCY 3;
# CONFIGURE CONTROLFILE AUTOBACKUP ON;
# CONFIGURE CONTROLFILE AUTOBACKUP FORMAT FOR DEVICE TYPE DISK TO '+BACK/%F';

# cd /app/oracle
# mkdir -p rman_backup/log
# cd rman_backup

# ASM BACKUP DISK is "+BACK".

$ cat rman_back.sh

#!/bin/bash

source ~/.bash_profile;

export DATE=`which date`

export DATE_W=`$DATE +%u`

export CURRENT_DATE=`$DATE +%F`

export RMAN=$ORACLE_HOME/bin

export BACK_LOG='/app/oracle/rman_backup/log'

# One week rman backup of incremental level 0 on Saturday and incremental level 1 on Sunday ~ Friday at 01:00 am.

case $DATE_W in

5)

$RMAN/rman nocatalog log $BACK_LOG/level0_$CURRENT_DATE.log <<EOF
connect target /
run {
allocate channel d1 type disk maxpiecesize 16g;
allocate channel d2 type disk maxpiecesize 16g;
allocate channel d3 type disk maxpiecesize 16g;
allocate channel d4 type disk maxpiecesize 16g;
backup incremental level 0 database format '+BACK' include current controlfile plus archivelog format '+BACK' delete input;
release channel d4;
release channel d3;
release channel d2;
release channel d1;
}
crosscheck backup;
crosscheck archivelog all;
exit;
EOF

# Maintenace rman backup of last week.

$RMAN/rman nocatalog log $BACK_LOG/maintenance_$CURRENT_DATE.log <<EOF
connect target /
report obsolete;
delete noprompt expired backup;
allocate channel for maintenance type disk;
delete noprompt obsolete device type disk;
exit;
EOF
;;

1|2|3|4|6|7)

$RMAN/rman nocatalog log $BACK_LOG/level1_$CURRENT_DATE.log <<EOF
connect target /
run {
allocate channel d1 type disk maxpiecesize 8g;
allocate channel d2 type disk maxpiecesize 8g;
allocate channel d3 type disk maxpiecesize 8g;
allocate channel d4 type disk maxpiecesize 8g;
backup incremental level 1 database format '+BACK' include current controlfile plus archivelog format '+BACK' delete input;
release channel d4;
release channel d3;
release channel d2;
release channel d1;
}
crosscheck backup;
crosscheck archivelog all;
exit;
EOF
;;
esac
