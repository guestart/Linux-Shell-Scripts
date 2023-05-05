#!/bin/bash

chmod +s `which netstat`;

# lsnr_port=`su - oracle -c "lsnrctl status | grep PORT | tail -1 | awk -F '=' '{print \$6}' | awk -F ')' '{print \$1}'"`
lsnr_port=$(su - oracle -c "lsnrctl status | grep PORT | tail -1 | awk -F '=' '{print \$6}' | awk -F ')' '{print \$1}'")

su - oracle -c "netstat -antp | grep ${lsnr_port} | grep -v "asm_" | grep -v "ora_" | grep -v "tnslsnr" | grep "ESTABLISHED" | awk -F ' ' '{print \$7,\$5}' | awk -F ':' '{print \$1}' | tr '/' ' ' | awk -F ' ' '{print \$1,\$3}'" > /tmp/spid_and_ip.txt

su - oracle -c "sqlplus -s / as sysdba" <<eof
set feedback off
create or replace directory exttab as '/tmp';
grant read on directory exttab to sys;
drop table clientip purge;
create table clientip (
  spid varchar2(24),
  ip_addr varchar2(15)
) organization external
( type oracle_loader
  default directory exttab
  access parameters
  ( records delimited by newline
    fields terminated by whitespace
    reject rows with all null fields
  )
  location ('spid_and_ip.txt')
) reject limit unlimited;
set feedback on
exit;
eof

su - oracle -c "sqlplus -s / as sysdba" <<eof
SET LINESIZE 300
SET PAGESIZE 300
COL host_name FOR a15
COL curr_host_name FOR a15
COL username FOR a20
COL spid FOR a10
COL machine FOR a30
WITH sess AS (
SELECT i.instance_number,
       i.host_name,
       case when i.host_name in (select host_name from v\$instance) then i.host_name
       else null
       end curr_host_name,
       s.sid,
       s.serial#,
       s.username,
       p.spid,
       s.machine
FROM gv\$instance i, gv\$session s, gv\$process p
WHERE i.instance_number = s.inst_id
AND s.inst_id = p.inst_id
AND s.paddr = p.addr
AND s.username IS NOT NULL
AND s.type = 'USER'
AND s.program NOT LIKE 'oracle%'
AND p.background IS NULL
AND i.host_name <> s.machine
ORDER BY i.instance_number
)
SELECT s.*, c.ip_addr
FROM sess s, clientip c
WHERE s.spid = c.spid;
exit;
eof
