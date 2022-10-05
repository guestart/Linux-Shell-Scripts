#!/bin/bash

systempwd=$1

function f_oracmd {
typeset _oracmd="$@"
su - oracle -c "sqlplus -S / as sysdba"<<EOF
whenever oserror exit 20;
whenever sqlerror exit 20;
set heading off;
set feedback off; 
set pagesize 0;
set verify off;
set echo off;
set numwidth 4;
${_oracmd}
exit;
EOF
}

function f_oracmd2 {
typeset _tns="$1"
typeset _oracmd2="$2"
su - oracle -c "sqlplus -S system/${systempwd}@${_tns}"<<EOF
whenever oserror exit 20;
whenever sqlerror exit 20;
set heading off;
set feedback off; 
set pagesize 0;
set verify off;
set echo off;
set numwidth 4;
${_oracmd2}
exit;
EOF
}

#checking the ip address of local server:
#select utl_inaddr.get_host_address from dual;
#ping `hostname` -c 1 | grep from | awk -F ':' '{print $1}' | awk -F '(' '{print $2}' | awk -F ')' '{print $1}'
#ping scanip -c 1 | grep from | awk -F ':' '{print $1}' | awk -F '(' '{print $2}' | awk -F ')' '{print $1}'

dbname=$(f_oracmd "select value from v\$parameter where name = 'db_name';")
db_unq_name=$(f_oracmd "select value from v\$parameter where name = 'db_unique_name';")
db_role=$(f_oracmd "select database_role from v\$database;")
clu_db=$(f_oracmd "select value from v\$parameter where name = 'cluster_database';")
dg_config=$(f_oracmd "select value from v\$parameter where name = 'log_archive_config';")
log_arch_dest=$(f_oracmd "select value from v\$parameter where name not like 'log_archive_dest_state_%' and name like 'log_archive_dest_%' and value is not null and (value like 'service%' or value like 'SERVICE%');")
dg_config_value=$(echo ${dg_config} | awk -F '(' '{print $2}' | awk -F ')' '{print $1}')

#dgconfig="DG_CONFIG=(orcl,orcldg,orcldg2)"
#dgconfig_value="orcl,orcldg,orcldg2"
#dg_env_nums=$(echo ${dg_config_value} | awk -F ',' '{print NF}')
#service=orcl19dg21 lgwr async noaffirm valid_for=(online_logfiles,primary_role) db_unique_name=orcl19dg21

#su - oracle -c "echo $ORACLE_HOME"
#[root@demo50 ~]# su - oracle -c "echo $ORACLE_HOME"
#
#[root@demo50 ~]# 

#su - oracle -c "env | grep ORACLE_HOME"
#ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1

#su - oracle -c "env | grep ORACLE_HOME | awk -F '=' '{print $2}'"
#[root@demo50 ~]# su - oracle -c "env | grep ORACLE_HOME | awk -F '=' '{print $2}'"
#ORACLE_HOME=/u01/app/oracle/product/11.2.0/db_1

oraclehome=$(su - oracle -c "env | grep ORACLE_HOME")
orac_home=$(echo ${oraclehome} | awk -F '=' '{print $2}')

#cat ${orac_home}/network/admin/tnsnames.ora | sed '/^$/d' $1 | sed 's/ //g' | sed ':a;N;$!ba;s/\=\n/\=/g' | sed ':a;N;$!ba;s/\n(/(/g' | sed ':a;N;$!ba;s/\n)/)/g'

if [ "${clu_db}" = "TRUE" ] && [ "${db_role}" = "PRIMARY" -o "${db_role}" = "PHYSICAL STANDBY" ]; then
  scanip_name=$(echo $(f_oracmd "select value from v\$parameter where name = 'remote_listener';") | awk -F ':' '{print $1}')
  scanip_address=$(ping ${scanip_name} -c 1 | grep from | awk -F ':' '{print $1}' | awk -F '(' '{print $2}' | awk -F ')' '{print $1}')
  listener_port=$(echo $(f_oracmd "select value from v\$parameter where name = 'remote_listener';") | awk -F ':' '{print $2}')
  echo "**********The Local Oracle Database Info**********"
  echo "SCAN IP: ${scanip_address}"
  echo "LISTENER PORT: ${listener_port}"
  echo "DATABASE NAME: ${dbname}"
  echo "DATABASE UNIQUE NAME: ${db_unq_name}"
  echo "DATABASE TYPE: Real Application Cluster"
  echo "DATABASE ROLE: ${db_role}"
  echo -e "**********************************************\n"
  if [ -z "${dg_config}" ]; then
    echo "The primary database of oracle rac does not meet the data guard architecture."
  elif [ ! -z "${dg_config}" ] && [ ! -z "${log_arch_dest}" ]; then
    for i in $(echo ${dg_config_value} | sed "s/,/ /g")
    do
      if [ "${i}" != "${db_unq_name}" ]; then 
        tns=${i}
        tns_remote=$(sed '/^$/d' ${orac_home}/network/admin/tnsnames.ora | sed 's/ //g' | sed ':a;N;$!ba;s/\=\n/\=/g' | sed ':a;N;$!ba;s/\n(/(/g' | sed ':a;N;$!ba;s/\n)/)/g' | grep -w "\<${tns}\>")
        hostname_remote=$(echo ${tns_remote} | awk -F 'HOST=' '{print $2}' | awk -F ')' '{print $1}')
        regex="\b(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[1-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[1-9])\b"
        check_step=$(echo ${hostname_remote} | egrep $regex | wc -l)
        if [ ${check_step} -eq 0 ]; then
          ipaddress_remote=$(ping ${hostname_remote} -c 1 | grep from | awk -F ':' '{print $1}' | awk -F '(' '{print $2}' | awk -F ')' '{print $1}')
        else
          ipaddress_remote=${hostname_remote}
        fi
        listener_port_remote=$(echo ${tns_remote} | awk -F 'PORT=' '{print $2}' | awk -F ')' '{print $1}')
        dbname_remote=$(f_oracmd2 "${tns}" "select value from v\$parameter where name = 'db_name';")
        db_unq_name_remote=$(f_oracmd2 "${tns}" "select value from v\$parameter where name = 'db_unique_name';")
        
        clu_db_remote=$(f_oracmd2 "${tns}" "select value from v\$parameter where name = 'cluster_database';")
        db_role_remote=$(f_oracmd2 "${tns}" "select database_role from v\$database;")
        
        if [ "${clu_db_remote}" = "TRUE" ]; then
          echo "**********The Remote Oracle Database Info**********"
          echo "SCAN IP: ${ipaddress_remote}"
          echo "LISTENER PORT: ${listener_port_remote}"
          echo "DATABASE NAME: ${dbname_remote}"
          echo "DATABASE UNIQUE NAME: ${db_unq_name_remote}"
          echo "DATABASE TYPE: Real Application Cluster"
          echo "DATABASE ROLE: ${db_role_remote}"
          echo -e "***************************************************\n"
        else
          echo "**********The Remote Oracle Database Info**********"
          echo "IP ADDRESS: ${ipaddress_remote}"
          echo "LISTENER PORT: ${listener_port_remote}"
          echo "DATABASE NAME: ${dbname_remote}"
          echo "DATABASE UNIQUE NAME: ${db_unq_name_remote}"
          echo "DATABASE TYPE: Single Instance"
          echo "DATABASE ROLE: ${db_role_remote}"
          echo -e "***************************************************\n"
        fi
      fi
   done
  fi
elif [ "${clu_db}" = "FALSE" ] && [ "${db_role}" = "PRIMARY" -o "${db_role}" = "PHYSICAL STANDBY" ]; then
  ip_address=$(f_oracmd "select utl_inaddr.get_host_address from dual;")
  listener_port=$(sed '/^$/d' ${orac_home}/network/admin/listener.ora | sed 's/ //g' | sed ':a;N;$!ba;s/\=\n/\=/g' | sed ':a;N;$!ba;s/\n(/(/g' | sed ':a;N;$!ba;s/\n)/)/g' | grep "\<LISTENER\>" | awk -F 'PORT=' '{print $2}' | awk -F ')' '{print $1}')
  echo "**********The Local Oracle Database Info**********"
  echo "IP ADDRESS: ${ip_address}"
  echo "LISTENER PORT: ${listener_port}"
  echo "DATABASE NAME: ${dbname}"
  echo "DATABASE UNIQUE NAME: ${db_unq_name}"
  echo "DATABASE TYPE: Single Instance"
  echo "DATABASE ROLE: ${db_role}"
  echo -e "**************************************************\n"
  if [ -z "${dg_config}" ]; then
    echo "The primary database of oracle rac does not meet the data guard architecture."
  elif [ ! -z "${dg_config}" ] && [ ! -z "${log_arch_dest}" ]; then
    for i in $(echo ${dg_config_value} | sed "s/,/ /g")
    do
      if [ "${i}" != "${db_unq_name}" ]; then 
        tns=${i}
        tns_remote=$(sed '/^$/d' ${orac_home}/network/admin/tnsnames.ora | sed 's/ //g' | sed ':a;N;$!ba;s/\=\n/\=/g' | sed ':a;N;$!ba;s/\n(/(/g' | sed ':a;N;$!ba;s/\n)/)/g' | grep -w "\<${tns}\>")
        hostname_remote=$(echo ${tns_remote} | awk -F 'HOST=' '{print $2}' | awk -F ')' '{print $1}')
        regex="\b(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[1-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[0-9])\.(25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9][0-9]|[1-9])\b"
        check_step=$(echo ${hostname_remote} | egrep $regex | wc -l)
        if [ ${check_step} -eq 0 ]; then
          ipaddress_remote=$(ping ${hostname_remote} -c 1 | grep from | awk -F ':' '{print $1}' | awk -F '(' '{print $2}' | awk -F ')' '{print $1}')
        else
          ipaddress_remote=${hostname_remote}
        fi
        listener_port_remote=$(echo ${tns_remote} | awk -F 'PORT=' '{print $2}' | awk -F ')' '{print $1}')
        dbname_remote=$(f_oracmd2 "${tns}" "select value from v\$parameter where name = 'db_name';")
        db_unq_name_remote=$(f_oracmd2 "${tns}" "select value from v\$parameter where name = 'db_unique_name';")
        
        db_role_remote=$(f_oracmd2 "${tns}" "select database_role from v\$database;")
        
        echo "**********The Remote Oracle Database Info**********"
        echo "IP ADDRESS: ${ipaddress_remote}"
        echo "LISTENER PORT: ${listener_port_remote}"
        echo "DATABASE NAME: ${dbname_remote}"
        echo "DATABASE UNIQUE NAME: ${db_unq_name_remote}"
        echo "DATABASE TYPE: Single Instance"
        echo "DATABASE ROLE: ${db_role_remote}"
        echo -e "***************************************************\n"  
      fi
    done
  fi
fi

-- the approach running this shell script: switching to root user of target server and executing the script, e.g.
./oracle_dg_arch.recognize.sh sys (sys is a parameter called the shell script and it is a password by user system within oracle database) 

[root@testdb2 ~]# ./oracle_dg_arch.recognize.sh sys
**********The Local Oracle Database Info**********
IP ADDRESS: 192.168.12.32
LISTENER PORT: 1521
DATABASE NAME: orcl11
DATABASE UNIQUE NAME: orcl11dg49
DATABASE TYPE: Single Instance
DATABASE ROLE: PRIMARY
**************************************************

**********The Remote Oracle Database Info**********
IP ADDRESS: 192.168.1.194
LISTENER PORT: 1521
DATABASE NAME: orcl11
DATABASE UNIQUE NAME: orcl11
DATABASE TYPE: Single Instance
DATABASE ROLE: PHYSICAL STANDBY
***************************************************
