-- https://blog.csdn.net/zr3036720790/article/details/129351309
-- 形如
-- 1 443 3958
-- 2 200 4000
-- 多行的thread_arch_seq.txt文件, 用for循环前需要加 IFS=$'\n'

-- https://blog.csdn.net/theonegis/article/details/52751238/
-- 或者使用while循环 while read -r ln


#!/bin/bash
oracle_version=$1
oracle_sid=$2
source ~/${oracle_version}_${oracle_sid}.env;
IFS=$'\n'
sed -i '/^$/d' ~/tmp/${oracle_sid}/thread_arch_seq/thread_arch_seq.txt
for ln in `cat ~/tmp/${oracle_sid}/thread_arch_seq/thread_arch_seq.txt`
do
  threadN=`echo ${ln}`
  tn=`echo ${threadN} | awk -F ' ' '{print $1}'`
  arch_min_seq=`echo ${threadN} | awk -F ' ' '{print $2}'`
  arch_max_seq=`echo ${threadN} | awk -F ' ' '{print $3}'`
  rman target / << EOF > ~/tmp/bstsdb/thread_arch_seq/thread_arch_del_seq.log
  crosscheck archivelog all;
  delete noprompt archivelog from sequence ${arch_min_seq} until sequence `expr ${arch_max_seq} - 5` thread ${tn};
  crosscheck archivelog all;
  exit;
EOF
done


-- 在Linux平台下
-- Error 处理: /bin/bash^M: bad interpreter: No such file or directory
-- 
-- 解决办法: 使用在终端输入 sed -i 's/\r$//' sh文件名
-- 
-- 原因：sh文件在Windows的记事本中编辑过, 在Windows下每一行结尾是\n\r, 而Linux下则是\n,
-- 在Windows下编辑过的sh文件在Linux下打开看的时候 每一行的结尾就会多出一个字符\r.
-- 
-- 用 cat -A sh文件名 会看到这个\r字符被显示为^M.
-- 或 cat -vET sh文件名
-- 
-- A就是all, 所有的都显示, 也就是说\n\r默认不显示.
-- 
-- 怎么删除掉呢?
-- 
-- 正则表达式 sed -i 's/\r$//' sh文件名
-- 
-- -i 插入
-- s 替代模式
-- \r$ 表示任何以\r结束的字符
-- 
-- 整句意思就是 把以\r结束的字符换在空白


-- 在Windows平台下
-- 在Windows下notepad++编辑的shell脚本文件, 选择 视图 -> 显示符号 -> 显示行尾符 (和字符集无关)
-- 会看到CRLF, 即 \n\r
-- 按Ctrl+H, 调出替换对话框, 查找\n\r, 替换为\n, 点 全部替换.
