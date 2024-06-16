DG备库上新增 定时删除已经应用的归档日志的计划任务

$ mkdir -p ~/del_standby_arch
$ cd del_standby_arch/
$ mkdir -p ./log
$ 
$ vi del_standby_arch.sh
#!/bin/bash
source ~/.bash_profile;
dt=`date +%Y%m%d_%H%M%S`
log="/home/oracle/del_standby_arch/log/del_standby_arch_${dt}.log"

$ORACLE_HOME/bin/sqlplus -silent "/ as sysdba" << EOF > ${log}
set heading off;
set pagesize 0;
set term off;
set feedback off;
set linesize 32767;
select substr(name, 1)
select case substr(name, 1, 1)
       when '/' then 'rm -f '
       when '+' then 'asmcmd rm -f '
       end || name from v\$archived_log
where APPLIED = 'YES'
and DELETED = 'NO';
exit;
EOF

awk '{ if (NR == (total-4)) print $0 }' total=$(wc -l < ${log}) ${log}
sh ${log}

# 或如果在ASM环境
# for ln in `cat ${log} | wc -l | head -n-5`
# do
#   asmcmd << EOF
#   ${ln}
#   exit;
# EOF
# done

$ORACLE_HOME/bin/rman target / << EOF
crosscheck archivelog all;
delete noprompt expired archivelog all;
crosscheck archivelog all;
exit;
EOF
 
$ chmod a+x ./del_standby_arch.sh

$ crontab -l
00 08 * * 1,5 /home/oracle/del_standby_arch/del_standby_arch.sh
