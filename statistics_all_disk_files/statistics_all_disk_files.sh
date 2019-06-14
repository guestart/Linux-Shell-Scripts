#!/bin/bash

# +------------------------------------------------------------------------+
# |                              Quanwen Zhao                              |
# |                            guestart@163.com                            |
# |                        quanwenzhao.wordpress.com                       |
# |------------------------------------------------------------------------|
# |       Copyright (c) 2016-2018 Quanwen Zhao. All rights reserved.       |
# |------------------------------------------------------------------------|
# | DATABASE   : Oracle                                                    |
# |                                                                        |
# | FILE       : statistics_all_disk_files.sh                              |
# |                                                                        |
# | CLASS      : LINUX Bourne-Again Shell Scripts                          |
# |                                                                        |
# | PURPOSE    : This bash script file used to list every file with only   |
# |              reserving the format of date and count total files number |
# |              on each disk on Linux Server.                             |
# |                                                                        |
# | PARAMETERS : None.                                                     |
# |                                                                        |
# | MODIFIED   : 29/06/2018 (dd/mm/yyyy)                                   |
# |                                                                        |
# | NOTE       : As with any code, ensure to test this script in a         |
# |              development environment before attempting to run it in    |
# |              production.                                               |
# +------------------------------------------------------------------------+

# +------------------------------------------------------------------------+
# | GLOBAL VARIABLES ABOUT THE ABSOLUTE PATH OF THE SHELL COMMAND          |
# +------------------------------------------------------------------------+

export AWK=`which awk`
export CUT=`which cut`
export DU=`which du`
export ECHO=`which echo`
export GREP=`which grep`
export LS=`which ls`
export UNIQ=`which uniq`
export WC=`which wc`

# +------------------------------------------------------------------------+
# | GLOBAL VARIABLES ABOUT STRINGS AND ABSOLUTE PATH OF THE SHELL COMMAND  |
# +------------------------------------------------------------------------+

export DISK_ARRAY='HDB HDC HDD HDE HDF HDG HDH HDI HDJ HDK HDL HDM HDN HDO'
export OUTPUT_FILE='/home/oracle/statistics_all_disk_files.txt'

# +------------------------------------------------------------------------+
# | USING THE "FOR DO ... DONE" TO ACCOMPLISH THAT PURPOSE PREVIOUS        |
# +------------------------------------------------------------------------+

for i in $DISK_ARRAY
  do
    cd /$i;
    if [ `$LS -A | $WC -w` = 0 ]; then
      $ECHO -e "+---------+" >> $OUTPUT_FILE;
      $ECHO -e "|  *"$i"*  |" >> $OUTPUT_FILE;
      $ECHO -e "+---------+" >> $OUTPUT_FILE;
      $ECHO -e "\r" >> $OUTPUT_FILE;
      $ECHO "Total Nums: 0" >> $OUTPUT_FILE;
      $ECHO -e "\r" >> $OUTPUT_FILE; 
    else
      export FILE_STR=`$DU -h * | $AWK '{print $2}' | $CUT -d'_' -f5 | $GREP -v log | $GREP -v lost+found | $UNIQ`
      $ECHO -e "+---------+" >> $OUTPUT_FILE;
      $ECHO -e "|  *"$i"*  |" >> $OUTPUT_FILE;
      $ECHO -e "+---------+" >> $OUTPUT_FILE;
      $ECHO -e "\r" >> $OUTPUT_FILE;
     #$ECHO $FILE_STR >> $OUTPUT_FILE;
      num=0;
      for j in $FILE_STR
      do
        $ECHO ${j:0:8} >> $OUTPUT_FILE;
        num=$(($num+1));
        $ECHO -e "\r" >> $OUTPUT_FILE;
      done
      $ECHO "Total Nums: "$num >> $OUTPUT_FILE;
      $ECHO -e "\r" >> $OUTPUT_FILE;
    fi
  done
