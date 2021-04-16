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
# | File Name    : /tmp/test_mkdir.sh                                      |
# |                                                                        |
# | Author       : Quanwen Zhao                                            |
# |                                                                        |
# | Description  : This bash script file used to test creating a directory |
# |                                                                        |
# |                after obtaining the previous location by "basename".    |
# |                                                                        |
# | Call Syntax  : . /tmp/test_mkdir.sh                                    |
# |                                                                        |
# |                or                                                      |
# |                                                                        |
# |                sh /tmp/test_mkdir.sh                                   |
# |                                                                        |
# | Last Modified: 30/03/2021 (dd/mm/yyyy)                                 |
# |                                                                        |
# +------------------------------------------------------------------------+

function cp_oracle () {
  BACKUP_DIR=$1
  CP_TO_DIR=$2
  
  if [ ! -d "$CP_TO_DIR/`basename $BACKUP_DIR`" ]; then
    mkdir -p $CP_TO_DIR/`basename $BACKUP_DIR`
  fi
}

# You can assume that the location of directory "/tmp/rman_backup/expdp" is not existed.
cp_oracle /tmp/rman_backup/expdp /tmp/back

# The following demo is the result what I can expect.
# [oracle@sync_back tmp]$ . /tmp/test.sh
# [oracle@sync_back tmp]$ 
# [oracle@sync_back tmp]$ cd back/
# [oracle@sync_back back]$ ls
# expdp
