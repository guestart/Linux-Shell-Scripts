#!/bin/bash

# +-----------------------------------------------------------------------+
# |                                                                       |
# |                              Quanwen Zhao                             |
# |                                                                       |
# |                            guestart@163.com                           |
# |                                                                       |
# |                   https://quanwenzhao.wordpress.com                   |
# |                                                                       |
# |-----------------------------------------------------------------------|
# |                                                                       |
# |         Copyright (c) 2019 Quanwen Zhao. All rights reserved.         |
# |                                                                       |
# |-----------------------------------------------------------------------|
# |                                                                       |
# | Database   : Oracle                                                   |
# |                                                                       |
# | Os env     : Linux                                                    |
# |                                                                       |
# | File       : dig_ip_via_listener_log_xml.sh                           |
# |                                                                       |
# | Class      : Linux Bash script                                        |
# |                                                                       |
# | Purpose    : This bash script file used to dig/mine all ip addresses  |
# |                                                                       |
# |              connecting to oracle database server recently via oracle |
# |                                                                       |
# |              listener log file "log.xml".                             |
# |                                                                       |
# | Parameters : None.                                                    |
# |                                                                       |
# | Modified   : 08/15/2019 (mm/dd/yyyy)                                  |
# |                                                                       |
# | Note       : As with any code, ensure to test this script in a        |
# |                                                                       |
# |              development environment before attempting to run it in   |
# |                                                                       |
# |              production.                                              |
# |                                                                       |
# +-----------------------------------------------------------------------+

#source ~/.bash_profile;

export DATE_TIME=`which date`
#export HOST_NAME=`which hostname`
export DIR_NAME=`which dirname`

#loc_listener_log=$ORACLE_BASE'/diag/tnslsnr/'`${HOST_NAME}`'/listener/alert'
#loc_listener_log=`${DIR_NAME} $(lsnrctl status | awk '/Listener Log File/ {print $NF}')`

listener_name=`lsnrctl show current_listener | grep "Current" | awk '{print $NF}'`

listener_log=`lsnrctl status ${listener_name} | awk '/Listener Log File/ {print $NF}'`

echo
echo "========================================================================================"
echo "#                                                                                      #"
echo "# Now this Bash shell script will generate dig_ip_via_listener_log_xml_`date +%Y%m%d`.lst      #"
echo "#                                                                                      #"
echo "# Please patiently waiting for a while ......                                          #"
echo "#                                                                                      #"
echo "========================================================================================"
echo
echo 'Begin time: '$(${DATE_TIME} '+%Y-%m-%d %H:%M:%S')
echo

cat ${listener_log} | grep "HOST=" | grep establish | awk -F'=' '{print $(NF-1)}' | cut -d')' -f1 | sort -n | uniq > ~/dig_listener_log_xml_`date +%Y%m%d`.lst

# +-----------------------------------------------------------------------+
# |                                                                       |
# | Total three methods filtering out IP address via grep or egrep.       |
# |                                                                       |
# | 1. grep -o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"   |
# |                                                                       |
# | 2. grep -E  "([0-9]{1,3}\.){3}[0-9]{1,3}"                             |
# |                                                                       |
# | 3. egrep -o "([0-9]{1,3}\.){3}[0-9]{1,3}"                             |
# |                                                                       |
# +-----------------------------------------------------------------------+

cat ~/dig_listener_log_xml_`date +%Y%m%d`.lst | grep -E  "([0-9]{1,3}\.){3}[0-9]{1,3}" | sort -n | uniq > ~/dig_ip_via_listener_log_xml_`date +%Y%m%d`.lst

echo "============================================================================================"
echo "#                                                                                          #"
echo "# As you can see, the previous mentioned two files have been listed by following location. #"
echo "#                                                                                          #"
echo "============================================================================================"
echo
ls -lrth ~/dig_ip_via_listener_log_xml_`date +%Y%m%d`.lst | awk '{print $NF}'
echo
echo 'End time: '$(${DATE_TIME} '+%Y-%m-%d %H:%M:%S')
echo
