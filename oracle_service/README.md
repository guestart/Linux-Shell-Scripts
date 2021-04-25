# The Two Approach of Startup Oracle Instance(s) Automatically After Restarting Server 

### 1. Creating a Linux SHELL script `oracle` in directory `/etc/init.d/` and doing the further configuration

- #### About how to create `oracle`, see <a href="https://github.com/guestart/Linux-Shell-Scripts/blob/master/oracle_service/oracle">oracle</a>
- #### Doing the further configuration to `oracle`
  - ##### Changing file mode bits to `oracle`
  ```bash
  [root@test init.d]# pwd
  /etc/init.d
  [root@test init.d]# ls -lrht oracle
  -rw-r--r-- 1 root root 5.4K Apr 17 10:40 oracle
  [root@test init.d]# chmod 755 oracle
  [root@test init.d]# 
  [root@test init.d]# ls -lrht oracle
  -rwxr-xr-x 1 root root 5.4K Apr 17 10:40 oracle
  ```
  - ##### Adding this new service `oracle` for management by `chkconfig`
  ```bash
  [root@test init.d]# chkconfig --add oracle
  [root@test init.d]# 
  ```
  - ##### Checking list the service `oracle` which chkconfig knows about, and whether it's stopped or started in each runlevel
  ```bash
  [root@test init.d]# chkconfig --list oracle
  
  Note: This output shows SysV services only and does not include native
        systemd services. SysV configuration data might be overridden by native
        systemd configuration.
  
        If you want to list systemd services use 'systemctl list-unit-files'.
        To see services enabled on particular target use
        'systemctl list-dependencies [target]'.
  
  oracle          0:off   1:off   2:on    3:on    4:on    5:on    6:off
  ```
  - ##### You can also restart, stop or start the service `oracle` via `service` command
  ```bash
  [root@test ~]# service oracle restart
  /etc/init.d/oracle : (shutdown oracle database ...)
  /etc/init.d/oracle : (start oracle database ...)
  [root@test ~]# 
  [root@test ~]# service oracle stop
  /etc/init.d/oracle : (shutdown oracle database ...)
  [root@test ~]# 
  [root@test ~]# su - oracle
  [oracle@test ~]$ ps -ef | grep ora_
  oracle    20991  20823  0 09:42 pts/6    00:00:00 grep --color=auto ora_
  [oracle@test ~]$ 
  [oracle@test ~]$ lsnrctl status
  
  LSNRCTL for Linux: Version 19.3.0.0.0 - Production on 25-APR-2021 09:42:57
  
  Copyright (c) 1991, 2019, Oracle.  All rights reserved.
  
  Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=test)(PORT=1521)))
  TNS-12541: TNS:no listener
   TNS-12560: TNS:protocol adapter error
    TNS-00511: No listener
     Linux Error: 111: Connection refused
  [oracle@test ~]$ 
  [oracle@test ~]$ exit
  [root@test ~]# service oracle start
  /etc/init.d/oracle : (start oracle database ...)
  [root@test ~]# 
  [root@test ~]# su - oracle
  [oracle@test ~]$ ps -ef | grep ora_
  oracle    21316      1  0 09:45 ?        00:00:00 ora_pmon_testdb
  oracle    21318      1  0 09:45 ?        00:00:00 ora_clmn_testdb
  oracle    21320      1  0 09:45 ?        00:00:00 ora_psp0_testdb
  oracle    21323      1  2 09:45 ?        00:00:01 ora_vktm_testdb
  oracle    21327      1  0 09:45 ?        00:00:00 ora_gen0_testdb
  oracle    21329      1 15 09:45 ?        00:00:13 ora_mman_testdb
  oracle    21333      1  0 09:45 ?        00:00:00 ora_gen1_testdb
  oracle    21336      1  0 09:45 ?        00:00:00 ora_diag_testdb
  oracle    21338      1  0 09:45 ?        00:00:00 ora_ofsd_testdb
  oracle    21341      1  0 09:45 ?        00:00:00 ora_dbrm_testdb
  oracle    21343      1  1 09:45 ?        00:00:00 ora_vkrm_testdb
  oracle    21345      1  0 09:45 ?        00:00:00 ora_svcb_testdb
  oracle    21347      1  0 09:45 ?        00:00:00 ora_pman_testdb
  oracle    21349      1  2 09:45 ?        00:00:02 ora_dia0_testdb
  oracle    21351      1  0 09:45 ?        00:00:00 ora_dbw0_testdb
  oracle    21353      1  0 09:45 ?        00:00:00 ora_dbw1_testdb
  oracle    21356      1  0 09:45 ?        00:00:00 ora_dbw2_testdb
  oracle    21358      1  0 09:45 ?        00:00:00 ora_dbw3_testdb
  oracle    21360      1  0 09:45 ?        00:00:00 ora_dbw4_testdb
  oracle    21362      1  0 09:45 ?        00:00:00 ora_dbw5_testdb
  oracle    21364      1  0 09:45 ?        00:00:00 ora_dbw6_testdb
  oracle    21366      1  0 09:45 ?        00:00:00 ora_dbw7_testdb
  oracle    21368      1  0 09:45 ?        00:00:00 ora_dbw8_testdb
  oracle    21370      1  0 09:45 ?        00:00:00 ora_dbw9_testdb
  oracle    21372      1  0 09:45 ?        00:00:00 ora_lgwr_testdb
  oracle    21374      1  0 09:45 ?        00:00:00 ora_ckpt_testdb
  oracle    21376      1  0 09:45 ?        00:00:00 ora_lg00_testdb
  oracle    21378      1  0 09:45 ?        00:00:00 ora_smon_testdb
  oracle    21380      1  0 09:45 ?        00:00:00 ora_lg01_testdb
  oracle    21382      1  0 09:45 ?        00:00:00 ora_smco_testdb
  oracle    21384      1  0 09:45 ?        00:00:00 ora_lg02_testdb
  oracle    21386      1  0 09:45 ?        00:00:00 ora_reco_testdb
  oracle    21388      1  0 09:45 ?        00:00:00 ora_w000_testdb
  oracle    21390      1  0 09:45 ?        00:00:00 ora_lreg_testdb
  oracle    21392      1  0 09:45 ?        00:00:00 ora_lg03_testdb
  oracle    21394      1  0 09:45 ?        00:00:00 ora_pxmn_testdb
  oracle    21396      1  0 09:45 ?        00:00:00 ora_w001_testdb
  oracle    21400      1  4 09:45 ?        00:00:03 ora_mmon_testdb
  oracle    21402      1  0 09:45 ?        00:00:00 ora_mmnl_testdb
  oracle    21404      1  0 09:45 ?        00:00:00 ora_d000_testdb
  oracle    21406      1  0 09:45 ?        00:00:00 ora_s000_testdb
  oracle    21408      1  0 09:45 ?        00:00:00 ora_tmon_testdb
  oracle    21414      1  0 09:45 ?        00:00:00 ora_m000_testdb
  oracle    21416      1  0 09:45 ?        00:00:00 ora_m001_testdb
  oracle    21423      1  0 09:45 ?        00:00:00 ora_tt00_testdb
  oracle    21425      1  0 09:45 ?        00:00:00 ora_arc0_testdb
  oracle    21427      1  0 09:45 ?        00:00:00 ora_tt01_testdb
  oracle    21429      1  0 09:45 ?        00:00:00 ora_arc1_testdb
  oracle    21431      1  0 09:45 ?        00:00:00 ora_arc2_testdb
  oracle    21433      1  0 09:45 ?        00:00:00 ora_arc3_testdb
  oracle    21435      1  0 09:45 ?        00:00:00 ora_tt02_testdb
  oracle    21440      1  0 09:45 ?        00:00:00 ora_aqpc_testdb
  oracle    21443      1  2 09:45 ?        00:00:01 ora_cjq0_testdb
  oracle    21511      1  0 09:45 ?        00:00:00 ora_p000_testdb
  oracle    21513      1  0 09:45 ?        00:00:00 ora_p001_testdb
  oracle    21515      1  0 09:45 ?        00:00:00 ora_p002_testdb
  oracle    21517      1  0 09:45 ?        00:00:00 ora_p003_testdb
  oracle    21519      1  0 09:45 ?        00:00:00 ora_p004_testdb
  oracle    21521      1  0 09:45 ?        00:00:00 ora_p005_testdb
  oracle    21523      1  0 09:45 ?        00:00:00 ora_p006_testdb
  oracle    21525      1  0 09:45 ?        00:00:00 ora_p007_testdb
  oracle    21527      1  0 09:45 ?        00:00:00 ora_p008_testdb
  oracle    21529      1  0 09:45 ?        00:00:00 ora_p009_testdb
  oracle    21531      1  0 09:45 ?        00:00:00 ora_p00a_testdb
  oracle    21533      1  0 09:45 ?        00:00:00 ora_p00b_testdb
  oracle    21535      1  0 09:45 ?        00:00:00 ora_p00c_testdb
  oracle    21537      1  0 09:45 ?        00:00:00 ora_p00d_testdb
  oracle    21539      1  0 09:45 ?        00:00:00 ora_p00e_testdb
  oracle    21541      1  0 09:45 ?        00:00:00 ora_p00f_testdb
  oracle    21543      1  0 09:45 ?        00:00:00 ora_p00g_testdb
  oracle    21545      1  0 09:45 ?        00:00:00 ora_p00h_testdb
  oracle    21547      1  0 09:45 ?        00:00:00 ora_p00i_testdb
  oracle    21549      1  0 09:45 ?        00:00:00 ora_p00j_testdb
  oracle    21551      1  0 09:45 ?        00:00:00 ora_p00k_testdb
  oracle    21553      1  0 09:45 ?        00:00:00 ora_p00l_testdb
  oracle    21556      1  0 09:45 ?        00:00:00 ora_w002_testdb
  oracle    21559      1  0 09:45 ?        00:00:00 ora_p00m_testdb
  oracle    21561      1  0 09:45 ?        00:00:00 ora_p00n_testdb
  oracle    21563      1  0 09:45 ?        00:00:00 ora_p00o_testdb
  oracle    21565      1  0 09:45 ?        00:00:00 ora_p00p_testdb
  oracle    21567      1  0 09:45 ?        00:00:00 ora_p00q_testdb
  oracle    21569      1  0 09:45 ?        00:00:00 ora_p00r_testdb
  oracle    21571      1  0 09:45 ?        00:00:00 ora_p00s_testdb
  oracle    21573      1  0 09:45 ?        00:00:00 ora_p00t_testdb
  oracle    21575      1  0 09:45 ?        00:00:00 ora_p00u_testdb
  oracle    21578      1  0 09:45 ?        00:00:00 ora_p00v_testdb
  oracle    21580      1  0 09:45 ?        00:00:00 ora_p00w_testdb
  oracle    21582      1  0 09:45 ?        00:00:00 ora_p00x_testdb
  oracle    21584      1  0 09:45 ?        00:00:00 ora_p00y_testdb
  oracle    21586      1  0 09:45 ?        00:00:00 ora_p00z_testdb
  oracle    21588      1  0 09:45 ?        00:00:00 ora_p010_testdb
  oracle    21590      1  0 09:45 ?        00:00:00 ora_p011_testdb
  oracle    21592      1  0 09:45 ?        00:00:00 ora_p012_testdb
  oracle    21594      1  0 09:45 ?        00:00:00 ora_p013_testdb
  oracle    21596      1  0 09:45 ?        00:00:00 ora_p014_testdb
  oracle    21598      1  0 09:45 ?        00:00:00 ora_p015_testdb
  oracle    21600      1  0 09:45 ?        00:00:00 ora_p016_testdb
  oracle    21602      1  0 09:45 ?        00:00:00 ora_p017_testdb
  oracle    21604      1  0 09:45 ?        00:00:00 ora_p018_testdb
  oracle    21606      1  0 09:45 ?        00:00:00 ora_p019_testdb
  oracle    21612      1  0 09:45 ?        00:00:00 ora_p01a_testdb
  oracle    21620      1  0 09:45 ?        00:00:00 ora_p01b_testdb
  oracle    21636      1  0 09:45 ?        00:00:00 ora_p01c_testdb
  oracle    21669      1  0 09:45 ?        00:00:00 ora_p01d_testdb
  oracle    21690      1  0 09:45 ?        00:00:00 ora_p01e_testdb
  oracle    21747      1  0 09:45 ?        00:00:00 ora_p01f_testdb
  oracle    21752      1  0 09:45 ?        00:00:00 ora_p01g_testdb
  oracle    21754      1  0 09:45 ?        00:00:00 ora_p01h_testdb
  oracle    21783      1  0 09:45 ?        00:00:00 ora_p01i_testdb
  oracle    21838      1  0 09:45 ?        00:00:00 ora_p01j_testdb
  oracle    21841      1  0 09:45 ?        00:00:00 ora_p01k_testdb
  oracle    21845      1  0 09:45 ?        00:00:00 ora_p01l_testdb
  oracle    21866      1  0 09:45 ?        00:00:00 ora_p01m_testdb
  oracle    21875      1  0 09:45 ?        00:00:00 ora_p01n_testdb
  oracle    21890      1  0 09:45 ?        00:00:00 ora_p01o_testdb
  oracle    21906      1  0 09:45 ?        00:00:00 ora_p01p_testdb
  oracle    21929      1  0 09:45 ?        00:00:00 ora_p01q_testdb
  oracle    21968      1  0 09:45 ?        00:00:00 ora_p01r_testdb
  oracle    21970      1  0 09:45 ?        00:00:00 ora_p01s_testdb
  oracle    21973      1  0 09:45 ?        00:00:00 ora_p01t_testdb
  oracle    21977      1  0 09:45 ?        00:00:00 ora_p01u_testdb
  oracle    21979      1  0 09:45 ?        00:00:00 ora_p01v_testdb
  oracle    21981      1  0 09:45 ?        00:00:00 ora_p01w_testdb
  oracle    21996      1  0 09:45 ?        00:00:00 ora_p01x_testdb
  oracle    22006      1  0 09:45 ?        00:00:00 ora_p01y_testdb
  oracle    22008      1  0 09:45 ?        00:00:00 ora_p01z_testdb
  oracle    22010      1  0 09:45 ?        00:00:00 ora_p020_testdb
  oracle    22012      1  0 09:45 ?        00:00:00 ora_p021_testdb
  oracle    22014      1  0 09:45 ?        00:00:00 ora_p022_testdb
  oracle    22016      1  0 09:45 ?        00:00:00 ora_p023_testdb
  oracle    22018      1  0 09:45 ?        00:00:00 ora_p024_testdb
  oracle    22020      1  0 09:45 ?        00:00:00 ora_p025_testdb
  oracle    22022      1  0 09:45 ?        00:00:00 ora_p026_testdb
  oracle    22024      1  0 09:45 ?        00:00:00 ora_p027_testdb
  oracle    22026      1  0 09:45 ?        00:00:00 ora_p028_testdb
  oracle    22028      1  0 09:45 ?        00:00:00 ora_p029_testdb
  oracle    22031      1  0 09:45 ?        00:00:00 ora_p02a_testdb
  oracle    22033      1  0 09:45 ?        00:00:00 ora_p02b_testdb
  oracle    22035      1  0 09:45 ?        00:00:00 ora_p02c_testdb
  oracle    22037      1  0 09:45 ?        00:00:00 ora_p02d_testdb
  oracle    22039      1  0 09:45 ?        00:00:00 ora_p02e_testdb
  oracle    22041      1  0 09:45 ?        00:00:00 ora_p02f_testdb
  oracle    22043      1  0 09:45 ?        00:00:00 ora_p02g_testdb
  oracle    22045      1  0 09:45 ?        00:00:00 ora_p02h_testdb
  oracle    22047      1  0 09:45 ?        00:00:00 ora_p02i_testdb
  oracle    22049      1  0 09:45 ?        00:00:00 ora_p02j_testdb
  oracle    22051      1  0 09:45 ?        00:00:00 ora_p02k_testdb
  oracle    22053      1  0 09:45 ?        00:00:00 ora_p02l_testdb
  oracle    22055      1  0 09:45 ?        00:00:00 ora_p02m_testdb
  oracle    22057      1  0 09:45 ?        00:00:00 ora_p02n_testdb
  oracle    22059      1  0 09:45 ?        00:00:00 ora_p02o_testdb
  oracle    22061      1  0 09:45 ?        00:00:00 ora_p02p_testdb
  oracle    22063      1  0 09:45 ?        00:00:00 ora_p02q_testdb
  oracle    22065      1  0 09:45 ?        00:00:00 ora_p02r_testdb
  oracle    22067      1  0 09:45 ?        00:00:00 ora_p02s_testdb
  oracle    22069      1  0 09:45 ?        00:00:00 ora_p02t_testdb
  oracle    22071      1  0 09:45 ?        00:00:00 ora_p02u_testdb
  oracle    22073      1  0 09:45 ?        00:00:00 ora_p02v_testdb
  oracle    22075      1  0 09:45 ?        00:00:00 ora_p02w_testdb
  oracle    22082      1  0 09:45 ?        00:00:00 ora_p02x_testdb
  oracle    22084      1  0 09:45 ?        00:00:00 ora_p02y_testdb
  oracle    22086      1  0 09:45 ?        00:00:00 ora_p02z_testdb
  oracle    22088      1  0 09:45 ?        00:00:00 ora_p030_testdb
  oracle    22090      1  0 09:45 ?        00:00:00 ora_p031_testdb
  oracle    22092      1  0 09:45 ?        00:00:00 ora_p032_testdb
  oracle    22094      1  0 09:45 ?        00:00:00 ora_p033_testdb
  oracle    22096      1  0 09:45 ?        00:00:00 ora_p034_testdb
  oracle    22098      1  0 09:45 ?        00:00:00 ora_p035_testdb
  oracle    22100      1  0 09:45 ?        00:00:00 ora_p036_testdb
  oracle    22102      1  0 09:45 ?        00:00:00 ora_p037_testdb
  oracle    22104      1  0 09:45 ?        00:00:00 ora_p038_testdb
  oracle    22106      1  0 09:45 ?        00:00:00 ora_p039_testdb
  oracle    22108      1  0 09:45 ?        00:00:00 ora_p03a_testdb
  oracle    22110      1  0 09:45 ?        00:00:00 ora_p03b_testdb
  oracle    22112      1  0 09:45 ?        00:00:00 ora_p03c_testdb
  oracle    22114      1  0 09:45 ?        00:00:00 ora_p03d_testdb
  oracle    22116      1  0 09:45 ?        00:00:00 ora_p03e_testdb
  oracle    22118      1  0 09:45 ?        00:00:00 ora_p03f_testdb
  oracle    22120      1  0 09:45 ?        00:00:00 ora_p03g_testdb
  oracle    22122      1  0 09:45 ?        00:00:00 ora_p03h_testdb
  oracle    22125      1  0 09:45 ?        00:00:00 ora_p03i_testdb
  oracle    22127      1  0 09:45 ?        00:00:00 ora_p03j_testdb
  oracle    22129      1  0 09:45 ?        00:00:00 ora_p03k_testdb
  oracle    22131      1  0 09:45 ?        00:00:00 ora_p03l_testdb
  oracle    22133      1  0 09:45 ?        00:00:00 ora_p03m_testdb
  oracle    22135      1  0 09:45 ?        00:00:00 ora_p03n_testdb
  oracle    22137      1  0 09:45 ?        00:00:00 ora_p03o_testdb
  oracle    22139      1  0 09:45 ?        00:00:00 ora_p03p_testdb
  oracle    22141      1  0 09:45 ?        00:00:00 ora_p03q_testdb
  oracle    22143      1  0 09:45 ?        00:00:00 ora_p03r_testdb
  oracle    22145      1  0 09:45 ?        00:00:00 ora_p03s_testdb
  oracle    22147      1  0 09:45 ?        00:00:00 ora_w003_testdb
  oracle    22149      1  0 09:45 ?        00:00:00 ora_p03t_testdb
  oracle    22151      1  0 09:45 ?        00:00:00 ora_p03u_testdb
  oracle    22153      1  0 09:45 ?        00:00:00 ora_p03v_testdb
  oracle    22155      1  0 09:45 ?        00:00:00 ora_p03w_testdb
  oracle    22157      1  0 09:45 ?        00:00:00 ora_p03x_testdb
  oracle    22159      1  0 09:45 ?        00:00:00 ora_p03y_testdb
  oracle    22161      1  0 09:45 ?        00:00:00 ora_p03z_testdb
  oracle    22163      1  0 09:45 ?        00:00:00 ora_p040_testdb
  oracle    22165      1  0 09:45 ?        00:00:00 ora_p041_testdb
  oracle    22167      1  0 09:45 ?        00:00:00 ora_p042_testdb
  oracle    22169      1  0 09:45 ?        00:00:00 ora_p043_testdb
  oracle    22171      1  0 09:45 ?        00:00:00 ora_p044_testdb
  oracle    22173      1  0 09:45 ?        00:00:00 ora_p045_testdb
  oracle    22175      1  0 09:45 ?        00:00:00 ora_p046_testdb
  oracle    22177      1  0 09:45 ?        00:00:00 ora_p047_testdb
  oracle    22179      1  0 09:45 ?        00:00:00 ora_p048_testdb
  oracle    22181      1  0 09:45 ?        00:00:00 ora_p049_testdb
  oracle    22183      1  0 09:45 ?        00:00:00 ora_p04a_testdb
  oracle    22185      1  0 09:45 ?        00:00:00 ora_p04b_testdb
  oracle    22187      1  0 09:45 ?        00:00:00 ora_p04c_testdb
  oracle    22189      1  0 09:45 ?        00:00:00 ora_p04d_testdb
  oracle    22191      1  0 09:45 ?        00:00:00 ora_p04e_testdb
  oracle    22193      1  0 09:45 ?        00:00:00 ora_p04f_testdb
  oracle    22208      1  5 09:45 ?        00:00:03 ora_m002_testdb
  oracle    22233      1  0 09:45 ?        00:00:00 ora_qm02_testdb
  oracle    22237      1  0 09:45 ?        00:00:00 ora_q002_testdb
  oracle    22239      1  0 09:45 ?        00:00:00 ora_q003_testdb
  oracle    22242      1  0 09:45 ?        00:00:00 ora_w004_testdb
  oracle    22304  20823  0 09:46 pts/6    00:00:00 grep --color=auto ora_
  [oracle@test ~]$ 
  [oracle@test ~]$ lsnrctl status
  
  LSNRCTL for Linux: Version 19.3.0.0.0 - Production on 25-APR-2021 09:51:45
  
  Copyright (c) 1991, 2019, Oracle.  All rights reserved.
  
  Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=test)(PORT=1521)))
  STATUS of the LISTENER
  ------------------------
  Alias                     LISTENER
  Version                   TNSLSNR for Linux: Version 19.3.0.0.0 - Production
  Start Date                25-APR-2021 09:45:00
  Uptime                    0 days 0 hr. 6 min. 44 sec
  Trace Level               off
  Security                  ON: Local OS Authentication
  SNMP                      OFF
  Listener Parameter File   /opt/oracle/product/19c/dbhome_1/network/admin/listener.ora
  Listener Log File         /opt/oracle/diag/tnslsnr/ncet/listener/alert/log.xml
  Listening Endpoints Summary...
    (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=test)(PORT=1521)))
  The listener supports no services
  The command completed successfully
  ```

### 2. Creating a Linux SHELL script `automatically_open_oracle.sh` in home directory of `oracle` user and then invoking it in directory `/etc/rc.loal`

- #### About how to create `automatically_open_oracle.sh`, see <a href="https://github.com/guestart/Linux-Shell-Scripts/blob/master/oracle_service/automatically_open_oracle.sh">automatically_open_oracle.sh</a>
- #### Invoking `automatically_open_oracle.sh` in directory `/etc/rc.loal` 
```bash
[root@test ~]# cat /etc/rc.local
#!/bin/sh
# 
# This script will be executed *after* all the other init scripts.
# You can put your own initialization stuff in here if you don't
# want to do the full Sys V style init stuff.
# 
touch /var/lock/subsys/local

# Automatically Startup Oracle Database Instance after restarting server
# sh /home/oracle/automatically_open_oracle.sh
```

### 3. License

`oracle_service` is licensed under the **GNU** (a recursive acronym for "GNU's Not Unix!"), the Version `3.0` of `GENERAL PUBLIC LICENSE`.
You may obtain a copy of the License at <a href="https://www.gnu.org/licenses/gpl-3.0.html">GPL 3.0</a>.
