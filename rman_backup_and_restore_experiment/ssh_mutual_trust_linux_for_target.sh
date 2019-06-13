#!/bin/bash

# +-----------------------------------------------------------------------+
# |                              Quanwen Zhao                             |
# |                            guestart@163.com                           |
# |                        quanwenzhao.wordpress.com                      |
# |-----------------------------------------------------------------------|
# |      Copyright (c) 2016-2017 Quanwen Zhao. All rights reserved.       |
# |-----------------------------------------------------------------------|
# | DATABASE   : Oracle                                                   |
# | OS ENV     : Linux                                                    |
# | File       : ssh_mutual_trust_linux_for_target.sh                     |
# | CLASS      : LINUX Bourne-Again Shell Scripts                         |
# | PURPOSE    : This bash script file used to set ssh mutual trust       |
# |              between source and target linux server. Therefore, every |
# |              operation between two, such as ssh and scp, have no      |
# |              password to interaction.                                 |
# |                                                                       |
# | PARAMETERS : None.                                                    |
# |                                                                       |
# | MODIFIED   : 03/10/2017 (mm/dd/yyyy)                                  |
# |                                                                       |
# | NOTE       : As with any code, ensure to test this script in a        |
# |              development environment before attempting to run it in   |
# |              production.                                              |
# +-----------------------------------------------------------------------+

# +-----------------------------------------------------------------------+
# | EXPORT ENVIRONMENT VARIABLE OF ORACLE USER                            |
# +-----------------------------------------------------------------------+

source ~/.bash_profile;

# +-----------------------------------------------------------------------+
# | GLOBAL VARIABLES ABOUT STRINGS AND BACKTICK EXECUTION RESULT OF SHELL |
# +-----------------------------------------------------------------------+

export DATE=`which date`
export ECHO=`which echo`
export HOSTNAME=`which hostname`
export PING=`which ping`
export SSH_KEYGEN=`which ssh-keygen`
export SSH_COPY_ID=`which ssh-copy-id`
export TEE=`which tee`

export LOCAL_HOST=`$HOSTNAME`

# Define Remote Host, For example, REMOTE_HOST='orcl1', According to your situation to set.
# At same time, Please add the host name and IP address of the remote host to hosts file
# that is located in etc subdir of '/' directory in root user.
# For example, as follows:
# 127.0.0.1     localhost       localhost.localdomain
# ::1           localhost6      localhost6.localdomain6
# 172.16.10.13  orcl13
# 172.16.10.11  orac11  <<==  Remote Host's host name and IP address

export REMOTE_HOST='orac11'

export ALIVEHOST=""
export DEADHOST=""
export EXITCODE=""

export LOGFILE=/tmp/ssh_mutual_trust_`$DATE +%F-%H-%M-%S`.log

$ECHO "# +-----------------------------------------------------------------------+" | $TEE -a $LOGFILE
$ECHO "# | CHECKING IF THE REMOTE HOST ARE REACHABLE                             |" | $TEE -a $LOGFILE
$ECHO -e "# +-----------------------------------------------------------------------+\n" | $TEE -a $LOGFILE

$PING -c 5 -w 5 $REMOTE_HOST

EXITCODE=`$ECHO $?`

if [ $EXITCODE = 0 ]
then
  ALIVEHOST="$ALIVEHOST $REMOTE_HOST"
else
  DEADHOST="$DEADHOST $REMOTE_HOST"
fi

if test -z "$DEADHOST"
then
  $ECHO Remote host reachability check succeeded. | $TEE -a $LOGFILE
  $ECHO The following host is reachable: $ALIVEHOST. | $TEE -a $LOGFILE
  $ECHO -e "Proceeding further...\n" | $TEE -a $LOGFILE
else
  $ECHO Remote host reachability check failed. | $TEE -a $LOGFILE
  $ECHO The following host is not reachable: $DEADHOST. | $TEE -a $LOGFILE
  $ECHO -e "Exiting now...\n" | $TEE -a $LOGFILE
  exit 1
fi

$ECHO "# +-----------------------------------------------------------------------+" | $TEE -a $LOGFILE
$ECHO "# | CREATE SSH PRIVATE AND PUBLIC KEY,COPY PUBLIC KEY TO REMOTE HOST      |" | $TEE -a $LOGFILE
$ECHO -e "# +-----------------------------------------------------------------------+\n" | $TEE -a $LOGFILE
$ECHO "# +-----------------------------------------------------------------------+" | $TEE -a $LOGFILE
$ECHO "# | The script will setup SSH connectivity from local host to remote host.|" | $TEE -a $LOGFILE
$ECHO "# | After the script is executed, the user can use SSH to run commands on |" | $TEE -a $LOGFILE
$ECHO "# | the remote host or copy files between local host and the remote host  |" | $TEE -a $LOGFILE
$ECHO "# | without being prompted for passwords or confirmations.                |" | $TEE -a $LOGFILE
$ECHO "# |                                                                       |" | $TEE -a $LOGFILE
$ECHO "# | NOTE 1:                                                               |" | $TEE -a $LOGFILE
$ECHO "# | As part of the setup procedure, this script will use 'ssh' and 'scp'  |" | $TEE -a $LOGFILE
$ECHO "# | to copy files between the local host and the remote host. Since the   |" | $TEE -a $LOGFILE
$ECHO "# | script does not store passwords, you may be prompted for the pass-    |" | $TEE -a $LOGFILE
$ECHO "# | words during the execution of the script whenever 'ssh' or 'scp' is   |" | $TEE -a $LOGFILE
$ECHO "# | invoked.                                                              |" | $TEE -a $LOGFILE
$ECHO "# |                                                                       |" | $TEE -a $LOGFILE
$ECHO "# | NOTE 2:                                                               |" | $TEE -a $LOGFILE
$ECHO "# | As per ssh requirements, this script will secure the user home        |" | $TEE -a $LOGFILE
$ECHO "# | directory and the .ssh directory by revoking group and world write    |" | $TEE -a $LOGFILE
$ECHO "# | privileges to those directories.                                      |" | $TEE -a $LOGFILE
$ECHO "# +-----------------------------------------------------------------------+" | $TEE -a $LOGFILE
$ECHO -e "\nThe Local Host is: "$LOCAL_HOST | $TEE -a $LOGFILE
$ECHO -e "The Remote Host is: "$REMOTE_HOST"\n" | $TEE -a $LOGFILE
$SSH_KEYGEN -t rsa | $TEE -a $LOGFILE
$SSH_COPY_ID -i ~/.ssh/id_rsa.pub oracle@$REMOTE_HOST | $TEE -a $LOGFILE
