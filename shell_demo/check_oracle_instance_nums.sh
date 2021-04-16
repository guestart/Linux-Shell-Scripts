# +------------------------------------------------------------------------+
# |                              Quanwen Zhao                              |
# |                            guestart@163.com                            |
# |                        quanwenzhao.wordpress.com                       |
# |------------------------------------------------------------------------|
# |                                                                        |
# |          Copyright (c) 2021 - Quanwen Zhao. All rights reserved.       |
# |                                                                        |
# |------------------------------------------------------------------------|
# |                                                                        |
# | File Name    : ~/check_oracle_instance_nums.sh                         |
# |                                                                        |
# | Author       : Quanwen Zhao                                            |
# |                                                                        |
# | Description  : This bash script file used to check how many instances  |
# |                                                                        |
# |                in your Oracle Database Server.                         |
# |                                                                        |
# | Call Syntax  : . ~/check_oracle_instance_nums.sh                       |
# |                                                                        |
# |                or                                                      |
# |                                                                        |
# |                sh ~/check_oracle_instance_nums.sh                      |
# |                                                                        |
# | Last Modified: 16/04/2021 (dd/mm/yyyy)                                 |
# |                                                                        |
# +------------------------------------------------------------------------+

# +------------------------------------------------------------------------+
# |                                                                        |
# | Export environment variable of oracle user                             |
# |                                                                        |
# +------------------------------------------------------------------------+

source ~/.bash_profile;

# +------------------------------------------------------------------------+
# |                                                                        |
# | Define the absolute location of some internal SHELL commands           |
# |                                                                        |
# +------------------------------------------------------------------------+

export AWK=`which awk`
export BASENAME=`which basename`
export CAT=`which cat`
export CUT=`which cut`
export FIND=`which find`
export WC=`which wc`
export SORT=`which sort`

# +------------------------------------------------------------------------+
# |                                                                        |
# | Define some shell common variables                                     |
# |                                                                        |
# +------------------------------------------------------------------------+

export SPFILE_LOC_LIST=  
export INSTANCE_NUM=`find ${ORACLE_HOME}/dbs -name "spfile*.ora" | wc -l`
export INSTANCE_NAME_TMPFILE=/tmp/instance_name_list.lst

# +------------------------------------------------------------------------+
# |                                                                        |
# | The critical SHELL script for check_oracle_instance_nums.sh            |
# |                                                                        |
# +------------------------------------------------------------------------+

> ${INSTANCE_NAME_TMPFILE}

if [ ${INSTANCE_NUM} -gt 1 ]; then
  SPFILE_LOC_LIST=`$FIND ${ORACLE_HOME}/dbs -name "spfile*.ora" | $SORT -n`
  for n in ${SPFILE_LOC_LIST}
  do
    $BASENAME $n | $CUT -d'.' -f1 | $AWK '{print substr($1, length("spfile")+1)}' >> ${INSTANCE_NAME_TMPFILE}
  done
else
  $BASENAME ${SPFILE_LOC_LIST} | $CUT -d'.' -f1 | $AWK '{print substr($1, length("spfile")+1)}'>> ${INSTANCE_NAME_TMPFILE}
fi

$CAT ${INSTANCE_NAME_TMPFILE}
