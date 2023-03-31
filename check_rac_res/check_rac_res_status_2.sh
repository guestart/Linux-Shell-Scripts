#!/bin/bash

db_version=`sqlplus -s / as sysdba <<eof
set heading off
select substr(version, 1, 2) from v\\$instance;
set heading on
exit;
eof`

if [ "${db_version}" == "19" ]; then
  srvctl modify asm -count ALL
fi

> /tmp/all_rac_res.txt

all_rac_res_name=$(crsctl stat res | grep -E "NAME" | awk -F '=' '{print $2}' | awk -F '(' '{print $1}')

for arrn in ${all_rac_res_name}
do
  crsctl stat res ${arrn} | xargs >> /tmp/all_rac_res.txt
done

offline_rac_rec_name="ora.gsd ora.helper ora.proxy_advm ora.rhpserver ora.mgmt.ghchkpt.acfs ora.MGMT.GHCHKPT.advm"

> /tmp/offline_rac_res.txt

for orrn in ${offline_rac_rec_name}
do
  crsctl stat res ${orrn} | grep -v "CRS-2613" | xargs >> /tmp/offline_rac_res.txt
done

sed -i '/^$/d' /tmp/offline_rac_res.txt

echo -e "The TARGET and STATE status of rac resource is OFFLINE, INTERMEDIATE, or UNKNOWN, which is as below: \n"

grep -F -v -f /tmp/offline_rac_res.txt /tmp/all_rac_res.txt | grep -E "OFFLINE|INTERMEDIATE|UNKNOWN"
