#!/bin/bash

# +------------------------------------------------------------------------+
# |                                                                        |
# |                              Quanwen Zhao                              |
# |                                                                        |
# |                            guestart@163.com                            |
# |                                                                        |
# |                        quanwenzhao.wordpress.com                       |
# |                                                                        |
# |------------------------------------------------------------------------|
# |                                                                        |
# |          Copyright (c) 2021 -  Quanwen Zhao. All rights reserved.      |
# |                                                                        |
# |------------------------------------------------------------------------|
# |                                                                        |
# | File Name    : /tmp/check_shell_command_return_value.sh                |
# |                                                                        |
# | Author       : Quanwen Zhao                                            |
# |                                                                        |
# | Description  : This bash script file used to check the return value    |
# |                                                                        |
# |                of prior SHELL command that has finished running.       |
# |                                                                        |
# | Call Syntax  : . /tmp/check_shell_command_return_value.sh              |
# |                                                                        |
# |                or                                                      |
# |                                                                        |
# |                sh /tmp/check_shell_command_return_value.sh             |
# |                                                                        |
# | Last Modified: 03/04/2021 (dd/mm/yyyy)                                 |
# |                                                                        |
# +------------------------------------------------------------------------+

export ECHO=`which echo`
export FIND=`which find`
export GREP=`which grep`
export SORT=`which sort`

$FIND /tmp -type f | $SORT -nr
$ECHO $?

$FIND /tmp -type f | $SORT -nr | $GREP -v "/tmp"
$ECHO $?

# As you can see from the following demo showing the different return value "0" and "1"
# when running "find /tmp -type f | sort -nr" and "find /tmp -type f | sort -nr | grep -v "/tmp"".
# Because the former shell command has normally exited but the latter one has abnormally exited.

# [oracle@sync_back ~]$ find /tmp -type f | sort -nr
# /tmp/tmp_20210403033001_subdir_all.log
# /tmp/tmp_20210403033001_remote_subdir_all.log
# /tmp/tmp_20210403033001_remote_all.log
# /tmp/tmp_20210403033001_local_subdir_all.log
# /tmp/tmp_20210403033001_local_all.log
# /tmp/tmp_20210403033001_compare_all.log
# /tmp/tmp_20210402033001_subdir_all.log
# /tmp/tmp_20210402033001_remote_subdir_all.log
# /tmp/tmp_20210402033001_remote_all.log
# /tmp/tmp_20210402033001_local_subdir_all.log
# /tmp/tmp_20210402033001_local_all.log
# /tmp/tmp_20210402033001_compare_all.log
# [oracle@sync_back ~]$ 
# [oracle@sync_back ~]$ echo $?
# 0
# 
# [oracle@sync_back ~]$ find /tmp -type f | sort -nr | grep -v "/tmp"
# find: ‘/tmp/systemd-private-907eb49692214e69b9937a753ad79f4a-colord.service-W3iOxH’: Permission denied
# find: ‘/tmp/systemd-private-907eb49692214e69b9937a753ad79f4a-rtkit-daemon.service-58zymA’: Permission denied
# find: ‘/tmp/ssh-2m24EkjO9yjE’: Permission denied
# find: ‘/tmp/systemd-private-907eb49692214e69b9937a753ad79f4a-vmtoolsd.service-waYELc’: Permission denied
# find: ‘/tmp/systemd-private-907eb49692214e69b9937a753ad79f4a-cups.service-TvKFdR’: Permission denied
# find: ‘/tmp/.esd-0’: Permission denied
# [oracle@sync_back ~]$ 
# [oracle@sync_back ~]$ echo $?
# 1
