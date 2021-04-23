# Welcome to use RSYNC

### 1. What is RSYNC ?

`Rsync` is a fast and extraordinarily versatile file copying tool. It can copy locally, to/from another host over any remote shell, or to/from a remote rsync daemon.
It offers a large number of options that control every aspect of its behavior and permit very flexible specification of the set of files to be copied. It is famous for
its delta-transfer algorithm, which reduces the amount of data sent over the network by sending only the differences between the source files and the existing files in
the destination. Rsync is widely used for backups and mirroring and as an improved copy command for everyday use.

Rsync finds files that need to be transferred using a "quick check" algorithm (by default) that looks for files that have changed in size or in last-modified time.
Any changes in the other preserved attributes (as requested by options) are made on the destination file directly when the quick check indicates that the file’s data does
not need to be updated.

### 2. How to use RSYNC ?

Here we use `RSYNC` to synchronize oracle backup files from REMOTE server to local. Assuming that the hostname of REMOTE oracle database server is `prodb1` and the hostname
of local server is `sync_back`. The following steps are entire process using RSYNC to sync oracle backup files.

- Setting `SSH` mutual trust configuration on the LOCAL and REMOTE server
  - Creating rsa secret key on the LOCAL server
  ```bash
  [oracle@sync_back ~]$ ssh-keygen -t rsa
  Generating public/private rsa key pair.
  Enter file in which to save the key (/home/oracle/.ssh/id_rsa): 
  Created directory '/home/oracle/.ssh'.
  Enter passphrase (empty for no passphrase): 
  Enter same passphrase again: 
  Your identification has been saved in /home/oracle/.ssh/id_rsa.
  Your public key has been saved in /home/oracle/.ssh/id_rsa.pub.
  The key fingerprint is:
  2c:08:27:4e:5a:4a:b7:aa:49:52:47:ae:e8:0a:52:70 oracle@ysyk_back
  The key's randomart image is:
  +--[ RSA 2048]----+
  |                 |
  |                 |
  |..E.o            |
  |.O.*.. .         |
  |o +.+ . S        |
  | +.o   .         |
  |=o.              |
  |B.               |
  |=.               |
  +-----------------+
  [oracle@sync_back ~]$ cd .ssh/
  [oracle@sync_back .ssh]$ ls
  id_rsa  id_rsa.pub
  ```
  - Copying the public key file of LOCAL server to the REMOTE oracle database server
  ```bash
  [oracle@sync_back ~]$ ssh-copy-id -i ~/.ssh/id_rsa.pub oracle@xx.xxx.x.xx
  The authenticity of host 'xx.xxx.x.xx (xx.xxx.x.xx)' can't be established.
  RSA key fingerprint is 15:28:06:14:da:da:d3:5c:04:79:50:48:3e:b4:dc:bb.
  Are you sure you want to continue connecting (yes/no)? yes
  /bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
  /bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
  oracle@xx.xxx.x.xx's password: 
  
  Number of key(s) added: 1
  
  Now try logging into the machine, with:   "ssh 'oracle@xx.xxx.x.xx'"
  and check to make sure that only the key(s) you wanted were added.
  
  [oracle@sync_back ~]$ ssh oracle@xx.xxx.x.xx
  [oracle@prodb1 ~]$ 
  [oracle@prodb1 ~]$ exit
  logout
  Connection to xx.xxx.x.xx closed.
  [oracle@sync_back ~]$ 
  ```
- Checking the installing method of `RSYNC` on the REMOTE and LOCAL server (Generally speaking, after finished installing Linux OS will automatically install rsync)
```bash
[root@prodb1 ~]# rpm -qa | grep rsync
rsync-3.0.6-12.el6.x86_64

[root@sync_back ~]# rpm -qa | grep rsync
rsync-3.0.9-17.el7.x86_64
```
- Configuring `rsyncd.conf` on the REMOTE oracle database server (see <a href="https://github.com/guestart/Linux-Shell-Scripts/blob/master/rsync/remote_server_configuration/rsyncd.conf">rsyncd.conf</a>)
- Configuring `rsyncd.motd` on the REMOTE oracle database server (see <a href="https://github.com/guestart/Linux-Shell-Scripts/blob/master/rsync/remote_server_configuration/rsyncd.motd">rsyncd.motd</a>)
- Configuring `rsyncd.secrets` on the REMOTE oracle database server (see <a href="https://github.com/guestart/Linux-Shell-Scripts/blob/master/rsync/remote_server_configuration/rsyncd.secrets">rsyncd.secrets</a>)
- Configuring `rsyncd.conf` on the LOCAL server (see <a href="https://github.com/guestart/Linux-Shell-Scripts/blob/master/rsync/local_server_configuration/rsyncd.conf">rsyncd.conf</a>)
- Running `RSYNC` as a daemon process on the REMOTE oracle database server (or invoking it in /etc/rc.local in order to be able to automatically run it after restarting server)
```bash
[root@prodb1 ~]# /usr/bin/rsync --daemon --port=873 --config=/etc/rsyncd.conf
[root@prodb1 ~]# 
[root@prodb1 ~]# cat /etc/rc.local 
#!/bin/sh
#
# This script will be executed *after* all the other init scripts.
# You can put your own initialization stuff in here if you don't
# want to do the full Sys V style init stuff.

touch /var/lock/subsys/local

# Startup rsyncd process
/usr/bin/rsync --daemon --port=873 --config=/etc/rsyncd.conf >/dev/null 2>&1
```
- Running `RSYNC` as a daemon process on the LOCAL server (or invoking it in /etc/rc.loal in order to be able to automatically run it after restarting server)
```bash
[root@sync_back ~]# /bin/rsync --daemon --port=873 --config=/etc/rsyncd.conf
[root@sync_back ~]# 
[root@sync_back ~]# cat /etc/rc.local 
#!/bin/bash
# THIS FILE IS ADDED FOR COMPATIBILITY PURPOSES
#
# It is highly advisable to create own systemd services or udev rules
# to run scripts during boot instead of using this file.
#
# In contrast to previous versions due to parallel execution during boot
# this script will NOT be run after all other services.
#
# Please note that you must run 'chmod +x /etc/rc.d/rc.local' to ensure
# that this script will be executed during boot.

touch /var/lock/subsys/local

# Startup rsyncd process
/bin/rsync --daemon --port=873 --config=/etc/rsyncd.conf >/dev/null 2>&1
```
- Executing the Linux SHELL script <a href="https://github.com/guestart/Linux-Shell-Scripts/blob/master/rsync/rsync_backup_with_log_refresh.sh">rsync_backup_with_log_refresh.sh</a> on the LOCAL server at 03:30 every day
```bash
[oracle@sync_back ~]$ crontab -l
30 03 * * * ~/rsync_script/rsync_backup_with_log_refresh.sh
```

### 3. License

`RSYNC` is licensed under the **GNU** (a recursive acronym for "GNU's Not Unix!"), the Version `3.0` of `GENERAL PUBLIC LICENSE`.
You may obtain a copy of the License at <a href="https://www.gnu.org/licenses/gpl-3.0.html">GPL 3.0</a>.
