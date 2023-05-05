#!/usr/bin/ksh

# lsnr_port=`su - oracle -c "lsnrctl status | grep PORT | tail -1 | awk -F '=' '{print \$6}' | awk -F ')' '{print \$1}'"`
lsnr_port=$(su - oracle -c "lsnrctl status | grep PORT | tail -1 | awk -F '=' '{print \$6}' | awk -F ')' '{print \$1}'")

real_lsnr_port=$(echo ${lsnr_port} | awk -F ' ' '{print $5}')

# checking the entry of socket we have to execute the following command via root user only, otherwise, showing "rmsock : Unable to read kernel address xxxxxxxxxxxxxxxx, errno = 13".
netstat -Aan | grep ${real_lsnr_port} | grep "ESTABLISHED" | awk '{print $1}' | while read line; do echo "$line `rmsock $line tcpcb | awk '{print $(NF-1)}'`"; done > /tmp/socket_and_spid.txt

# Similarly the above suggestion it is the best to execute the following command via root user, if via oracle user, aix will report "awk: 0602-502 The statement cannot be correctly parsed".
netstat -Aan | grep ${real_lsnr_port} | grep "ESTABLISHED" | awk -F ' ' '{print $1,$6}' | awk -F '.' '{print $1"."$2"."$3"."$4}' > /tmp/socket_and_ip.txt

# To prevent outputing "[YOU HAVE NEW MAIL]" on any operation step of AIX we add ">>/dev/null" deliberately.
su - oracle -c "sqlplus -s / as sysdba" <<eof>>/dev/null
set feedback off
create or replace directory exttab as '/tmp';
drop table socket_and_spid purge;
create table socket_and_spid (
  socket varchar2(20),
  spid varchar2(24)
) organization external
( type oracle_loader
  default directory exttab
  access parameters
  ( records delimited by newline
    fields terminated by whitespace
    reject rows with all null fields
  )
  location ('socket_and_spid.txt')
) reject limit unlimited;
drop table socket_and_ip purge;
create table socket_and_ip (
  socket varchar2(20),
  ip_addr varchar2(15)
) organization external
( type oracle_loader
  default directory exttab
  access parameters
  ( records delimited by newline
    fields terminated by whitespace
    reject rows with all null fields
  )
  location ('socket_and_ip.txt')
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
),
sas_sai AS (
SELECT sas.spid, sai.ip_addr
FROM socket_and_spid sas, socket_and_ip sai
WHERE sas.socket = sai.socket
)
SELECT s.*, ss.ip_addr
FROM sess s, sas_sai ss
WHERE s.spid = ss.spid;
exit;
eof
