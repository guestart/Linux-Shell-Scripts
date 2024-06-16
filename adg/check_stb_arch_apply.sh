#!/bin/bash
oracle_version=$1
oracle_sid=$2
source ~/${oracle_version}_${oracle_sid}.env;
if [ ! -f ~/tmp/${oracle_sid}/thread_arch_seq/thread_arch_seq.txt ]; then
  mkdir -p ~/tmp/${oracle_sid}
  touch ~/tmp/${oracle_sid}/thread_arch_seq/thread_arch_seq.txt
fi
sqlplus -S / as sysdba << EOF
spool /home/oracle/tmp/${oracle_sid}/thread_arch_seq/thread_arch_seq.txt
set echo off
set trimspool on
set trimout on
set termout on
set heading off
set feedback off
select thread# || ' ' || min(sequence#) || ' ' || max(sequence#) as thread_mm_seq from v\$archived_log where APPLIED = 'YES' and DELETED = 'NO' group by thread# order by thread#;
spool off
exit
EOF

或

#!/bin/bash
oracle_version=$1
oracle_sid=$2
source ~/${oracle_version}_${oracle_sid}.env;
if [ ! -f ~/tmp/${oracle_sid}/thread_arch_seq/thread_arch_seq.txt ]; then
  mkdir -p ~/tmp/${oracle_sid}
  touch ~/tmp/${oracle_sid}/thread_arch_seq/thread_arch_seq.txt
fi
sqlplus -S / as sysdba << EOF > ~/tmp/${oracle_sid}/thread_arch_seq/thread_arch_seq.txt
set echo off
set trimspool on
set trimout on
set termout on
set heading off
set feedback off
select thread# || ' ' || min(sequence#) || ' ' || max(sequence#) as thread_mm_seq from v\$archived_log where APPLIED = 'YES' and DELETED = 'NO' group by thread# order by thread#;
exit
EOF
