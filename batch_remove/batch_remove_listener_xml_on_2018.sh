#/bin/bash

# +----------------------------------------------------------------------------+
# |                                                                            |
# | File Name    : batch_remove_listener_xml_on_2018.sh                        |
# |                                                                            |
# | Author       : Quanwen Zhao                                                |
# |                                                                            |
# | Description  : This bash script file used to remove listener log xml file  |
# |                                                                            |
# |                that located in "$ORACLE_BASE/diag/tnslsnr/$HOSTNAME        |
# |                                                                            |
# |                /listener/alert" directory on oracle user of Oracle         |
# |                                                                            |
# |                Database Server generated by 2018.                          |
# |                                                                            |
# | Call Syntax  : . ~/batch_remove_listener_xml_on_2018.sh                    |
# |                                                                            |
# |                or                                                          |
# |                                                                            |
# |                sh ~/batch_remove_listener_xml_on_2018.sh                   |
# |                                                                            |
# | Last Modified: 11/04/209 (mm/dd/yyyy)                                      |
# |                                                                            |
# +----------------------------------------------------------------------------+

# +----------------------------------------------------------------------------+
# |                                                                            |
# | EXPORT ENVIRONMENT VARIABLE OF ORACLE USER                                 |
# |                                                                            |
# +----------------------------------------------------------------------------+

source ~/.bash_profile;

# +----------------------------------------------------------------------------+
# |                                                                            |
# | DEFINE SOME SHELL STRING VARIABLES ON ABSOLUTE PATH OF EXTERNAL COMMAND    |
# |                                                                            |
# | AND DIRECTORY                                                              |
# |                                                                            |
# +----------------------------------------------------------------------------+

export AWK=`which awk`
export ECHO=`which echo`
export GREP=`which grep`
export HOSTNAME=`which hostname`
export LS=`which ls`
export RM=`which rm`
export WC=`which wc`

cd /u01/app/oracle/diag/tnslsnr/`$HOSTNAME`/listener/alert/

file_name=`$LS --full-time | $GREP '2018' | $AWK '{print $9}'`
file_count=`$LS --full-time | $GREP '2018' | $AWK '{print $9}' | $WC -l`

for file in $file_name
do
  $RM -rf $file;
  $ECHO -e "$file has been removed."
done
$ECHO -e
$ECHO -e "Total $file_count log.xml have been removed."