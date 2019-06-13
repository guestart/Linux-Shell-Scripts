----
总述
----

这个“README_CN.TXT”文件是专门用于在Oracle数据库服务器上做RMAN备份和恢复实验的。
有两台Oracle数据库服务器，一台是源Oracle数据库，即生产环境；另一台是目标Oracle数据库，
它只安装了Linux操作系统和Oracle数据库软件。我们需要在这台服务器上用源Oracle数据库
的RMAN备份集恢复出一个数据库。

--------------------------------------------------------
整个RMAN恢复过程包括5个SHELL脚本文件(包括每个脚本文件的介绍)
--------------------------------------------------------

-- 1. ssh_mutual_trust_linux_for_source.sh          ==> ( 在源主机上设置目标主机的SSH互信功能 )
-- 2. ssh_mutual_trust_linux_for_target.sh          ==> ( 在目标主机上设置源主机的SSH互信功能 )
-- 3. collect_info_from_source_oracle.sh            ==> ( 从源主机收集一些信息 )
-- 4. scp_log_file_to_target.sh                     ==> ( 远程复制文件"/tmp/source_oracle_dbinfo.log"到目标主机 )
-- 5. rman_restore_and_recover_to_target_oracle.sh  ==> ( 用RMAN还原和恢复Oracle到目标主机 )

------------------
执行SHELL脚本的流程
------------------

所有的SHELL脚本都是在Oracle用户下执行。

(1) 在源和目标的Oracle数据库服务器上设置SSH互信功能，即在源主机上执行脚本"ssh_mutual_trust_linux_for_source.sh"，
在目标主机上执行脚本"ssh_mutual_trust_linux_for_target.sh"；

(2) 在源主机上执行脚本"collect_info_from_source_oracle.sh"用来收集一些基本信息，然后再执行脚本"scp_log_file_to_target.sh"，
即远程复制文件"/tmp/source_oracle_dbinfo.log"到目标主机的"/tmp"目录；

(3) 在目标主机执行脚本"rman_restore_and_recover_to_target_oracle.sh"，用来还原和恢复Oracle数据库。
