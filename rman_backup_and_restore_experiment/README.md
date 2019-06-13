# Rman_Backup_And_Restore_Experiment

### README :

* [README_EN.TXT](https://github.com/guestart/rman_backup_and_restore_experiment/blob/master/README_EN.TXT) - The english version of introducing each shell script file's meaning and the order to execute it

* [README_CN.TXT](https://github.com/guestart/rman_backup_and_restore_experiment/blob/master/README_CN.TXT) - The chinese version of introducing each shell script file's meaning and the order to execute it

### ENTIRE SHELL SCRIPTS :

* [ssh_mutual_trust_linux_for_source.sh](https://github.com/guestart/rman_backup_and_restore_experiment/blob/master/ssh_mutual_trust_linux_for_source.sh) - Set target host's ssh mutual trust function on source host

* [ssh_mutual_trust_linux_for_target.sh](https://github.com/guestart/rman_backup_and_restore_experiment/blob/master/ssh_mutual_trust_linux_for_target.sh) - Set source host's ssh mutual trust function on target host

* [collect_info_from_source_oracle.sh](https://github.com/guestart/rman_backup_and_restore_experiment/blob/master/collect_info_from_source_oracle.sh) - Collect some information from source host

* [scp_log_file_to_target.sh](https://github.com/guestart/rman_backup_and_restore_experiment/blob/master/scp_log_file_to_target.sh) - Scp file "/tmp/source_oracle_dbinfo.log" to target host

* [rman_restore_and_recover_to_target_oracle.sh](https://github.com/guestart/rman_backup_and_restore_experiment/blob/master/rman_restore_and_recover_to_target_oracle.sh) - Use rman restore and recover oracle to target host

### RMAN VALIDATE SHELL SCRIPT :

* [rman_validate_v2.sh](https://github.com/guestart/rman_backup_and_restore_experiment/blob/master/rman_validate_v2.sh) - Validate the rman backupset on source host
