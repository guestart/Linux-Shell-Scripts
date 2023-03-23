#!/bin/bash

source ~/.bash_profile;

arch_log_list=`sqlplus -s / as sysdba <<eof
archive log list;
exit;
eof`

arch_mode=`echo ${arch_log_list} | awk -F ' ' '{print $4}'`

if [ "${arch_mode}" == "No" ]; then
  echo "The Oracle Database has been in No Archive Mode."
elif [ "${arch_mode}" == "Archive" ]; then
  arch_loc=`echo ${arch_log_list} | awk -F ' ' '{print $11}'`
  if [ "${arch_loc}" == "USE_DB_RECOVERY_FILE_DEST" ]; then
    aup_sql=`sqlplus -s / as sysdba <<eof
set heading off
select file_type, percent_space_used from v\\$recovery_area_usage where file_type = 'ARCHIVED LOG';
set heading on
exit;
eof`
   arch_used_percent=`echo ${aup_sql} | awk -F ' ' '{print $3}'`
  else
    arch_disk_type=`echo ${arch_loc} | awk '{print substr($0, 0, 1)}'`
    case ${arch_disk_type} in
    "/")
    arch_used_size=`du -sm ${arch_loc} | awk -F ' ' '{print $1}'`
    arch_total_size=`df -m ${arch_loc} | grep -v "Filesystem" | xargs | awk '{print $2}'`
    arch_used_percent=`awk 'BEGIN {printf "%.2f\n", ('${arch_used_size}'/'${arch_total_size}')*100}'`
    ;;
    "+")
    aup_sql=`sqlplus -s / as sysdba <<eof
set heading off
with af as
(select group_number,
        redundancy,
        round(sum(space)/1024/1024/1024, 2) used_gb
 from v\\$asm_file
 where type in ('ARCHIVELOG')
 group by group_number,
          redundancy
),
aug as
(select af.group_number,
        case af.redundancy
          when 'MIRROR' then af.used_gb/2
          when 'HIGH'   then af.used_gb/3
        end act_used_gb
 from af
)
select ad.name as ASM_DISK_NAME,
       aug.act_used_gb as ARC_USED_GB,
       round(af.used_gb/(ad.total_mb/1024), 4)*100 as PERCENT_SPACE_USED
from v\\$asm_diskgroup ad, af, aug
where ad.group_number = af.group_number
and af.group_number = aug.group_number;
set heading on
exit;
eof`
    arch_used_percent=`echo ${aup_sql} | awk -F ' ' '{print $3}'`
    ;;
    esac
  fi
  echo "The Oracle Database Archived Log used percent is: ${arch_used_percent}%."
fi
