#!/bin/bash

# Directly running the script on grid user of the Linux server that has been deploying oracle rac in order to check the status of some critical rac resources.

export ECHO=`which echo`

$ECHO -e "\033[31;7m#######################\033[0m"
$ECHO -e "\033[31;7m# Node Numbers on RAC #\033[0m"
$ECHO -e "\033[31;7m#######################\033[0m"

olsnodes

$ECHO -e "\033[31;7m#####################\033[0m"
$ECHO -e "\033[31;7m# ASM Status on RAC #\033[0m"
$ECHO -e "\033[31;7m#####################\033[0m"

srvctl status asm

$ECHO -e "\033[31;7m###########################\033[0m"
$ECHO -e "\033[31;7m# Diskgroup Status on RAC #\033[0m"
$ECHO -e "\033[31;7m###########################\033[0m"

asm_disk_name=$(asmcmd lsdg | grep -v "Name" | awk -F ' ' '{print $NF}' | awk -F '/' '{print $1}')
for adn in ${asm_disk_name}
do
  srvctl status diskgroup -g ${adn} -a -v
done

$ECHO -e "\033[31;7m#########################\033[0m"
$ECHO -e "\033[31;7m# Network Status on RAC #\033[0m"
$ECHO -e "\033[31;7m#########################\033[0m"

srvctl status nodeapps | grep -E "Network"

$ECHO -e "\033[31;7m#####################\033[0m"
$ECHO -e "\033[31;7m# VIP Status on RAC #\033[0m"
$ECHO -e "\033[31;7m#####################\033[0m"

srvctl status nodeapps | grep -E "VIP"

$ECHO -e "\033[31;7m##########################\033[0m"
$ECHO -e "\033[31;7m# SCAN VIP Status on RAC #\033[0m"
$ECHO -e "\033[31;7m##########################\033[0m"

srvctl status scan

$ECHO -e "\033[31;7m###################################################\033[0m"
$ECHO -e "\033[31;7m# ONS (Oracle Notification Service) Status on RAC #\033[0m"
$ECHO -e "\033[31;7m###################################################\033[0m"

srvctl status nodeapps | grep -E "ONS"

$ECHO -e "\033[31;7m####################################################\033[0m"
$ECHO -e "\033[31;7m# CVU (Cluster Verification Utility) Status on RAC #\033[0m"
$ECHO -e "\033[31;7m####################################################\033[0m"

srvctl status cvu

$ECHO -e "\033[31;7m##########################\033[0m"
$ECHO -e "\033[31;7m# Listener Status on RAC #\033[0m"
$ECHO -e "\033[31;7m##########################\033[0m"

srvctl status listener

$ECHO -e "\033[31;7m###############################\033[0m"
$ECHO -e "\033[31;7m# SCAN Listener Status on RAC #\033[0m"
$ECHO -e "\033[31;7m###############################\033[0m"

srvctl status scan_listener

$ECHO -e "\033[31;7m########################\033[0m"
$ECHO -e "\033[31;7m# Database Name on RAC #\033[0m"
$ECHO -e "\033[31;7m########################\033[0m"

srvctl config database

$ECHO -e "\033[31;7m###################################\033[0m"
$ECHO -e "\033[31;7m# Database Instance Status on RAC #\033[0m"
$ECHO -e "\033[31;7m###################################\033[0m"

database_name=$(srvctl config database)
for dn in ${database_name}
do
  srvctl status database -d ${dn} -v
done
