#!/bin/bash

# Execute/run this bash shell script "oracle_logo.sh" at the end of ".bash_profile", which is located on the home directory of oracle user.

# Assume that "oracle_logo.sh" has been placed to "~", Just like this, ". ~/oracle_logo.sh".

# +-----------------------------------------------------------------------+
# |                                                                       |
# |                              Quanwen Zhao                             |
# |                                                                       |
# |                            guestart@163.com                           |
# |                                                                       |
# |                        quanwenzhao.wordpress.com                      |
# |                                                                       |
# |-----------------------------------------------------------------------|
# |                                                                       |
# |      Copyright (c) 2016-2017 Quanwen Zhao. All rights reserved.       |
# |                                                                       |
# |-----------------------------------------------------------------------|
# |                                                                       |
# | OS ENV     : Linux                                                    |
# |                                                                       |
# | File       : oracle_logo.sh                                           |
# |                                                                       |
# | CLASS      : LINUX Bourne-Again Shell Scripts                         |
# |                                                                       |
# | PURPOSE    : This bash script file used to show banner logo of oracle |
# |                                                                       |
# |              database server.                                         |
# |                                                                       |
# | PARAMETERS : None.                                                    |
# |                                                                       |
# | MODIFIED   : 13/06/2017 (dd/mm/yyyy)                                  |
# |                                                                       |
# +-----------------------------------------------------------------------+

# +-----------------------------------------------------------------------+
# |                                                                       |
# | EXPORT ENVIRONMENT VARIABLE OF ROOT USER                              |
# |                                                                       |
# +-----------------------------------------------------------------------+

# Please don't execute this statement, otherwise prompt error: Segmentation fault (core dumped).

# source ~/.bash_profile; 

# +-----------------------------------------------------------------------+
# |                                                                       |
# | GLOBAL VARIABLES ABOUT STRINGS AND BACKTICK EXECUTION RESULT OF SHELL |
# |                                                                       |
# +-----------------------------------------------------------------------+

export ECHO=`which echo`

export LS=`which ls`

# +-----------------------------------------------------------------------+
# |                                                                       |
# | PRINT BANNER LOGO WITH ECHO COMMAND                                   |
# |                                                                       |
# +-----------------------------------------------------------------------+

$ECHO -e "\033[31;7m######################################################################################\033[0m"
$ECHO -e "\033[31;7m#                                                                                    #\033[0m"
$ECHO -e "\033[31;7m#     +-------+     +-------        +         +-------/  +            +-------/ (R)  #\033[0m"
$ECHO -e "\033[31;7m#    (         )    |       )      / \        (          |            (              #\033[0m"
$ECHO -e "\033[31;7m#   (           )   |      )      /   \      (           |           (               #\033[0m"
$ECHO -e "\033[31;7m#  (             )  |------      /     \    (            |          (-------/        #\033[0m"
$ECHO -e "\033[31;7m#   (           )   |    \      / ----- \    (           |           (               #\033[0m"
$ECHO -e "\033[31;7m#    (         )    |     \    |         |    (          |       /    (              #\033[0m"
$ECHO -e "\033[31;7m#     +-------+     -      --  -         -    +-------/  +-------+    +-------/      #\033[0m"
$ECHO -e "\033[31;7m#                                                                                    #\033[0m"
$ECHO -e "\033[31;7m#                                                                                    #\033[0m"
$ECHO -e "\033[31;7m#                                              +----------------------------------+  #\033[0m"
$ECHO -e "\033[31;7m#                                              | Applications & Platform Services |  #\033[0m"
$ECHO -e "\033[31;7m#                                              +----------------------------------+  #\033[0m"
$ECHO -e "\033[31;7m#                                                                                    #\033[0m"
$ECHO -e "\033[31;7m######################################################################################\033[0m"
