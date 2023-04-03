[grid@xxxx01 ~]$ cat /home/oracle/purge_listener_xml.sh
#!/bin/bash
source ~/.bash_profile

lsnr_used_ratio=`df -h /u01 | grep -v "Filesystem" | xargs | awk -F ' ' '{print $5}' | awk -F '%' '{print $1}'`

if [ ${lsnr_used_ratio} -ge 75 ]; then
  rm -rf /u01/app/oracle/diag/tnslsnr/xxxx01/listener/alert/log_*.xml
  rm -rf /u01/app/11.2.0/grid/log/diag/tnslsnr/xxxx01/listener_scan1/alert/log_*.xml
fi

[grid@xxxx02 ~]$ cat /home/oracle/purge_listener_xml.sh
#!/bin/bash
source ~/.bash_profile

lsnr_used_ratio=`df -h /u01 | grep -v "Filesystem" | xargs | awk -F ' ' '{print $5}' | awk -F '%' '{print $1}'`

if [ ${lsnr_used_ratio} -ge 75 ]; then
  rm -rf /u01/app/oracle/diag/tnslsnr/xxxx02/listener/alert/log_*.xml
  rm -rf /u01/app/11.2.0/grid/log/diag/tnslsnr/xxxx02/listener_scan1/alert/log_*.xml
fi

[grid@xxxx01 ~]$ crontab -l
00 20 * * * /home/grid/purge_listener_xml.sh

[grid@xxxx02 ~]$ crontab -l
00 20 * * * /home/grid/purge_listener_xml.sh
