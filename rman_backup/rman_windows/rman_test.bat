@echo off

set oracle_sid=test

D:\oracle\ora92\bin\rman target sys/xxxx@test nocatalog cmdfile='e:\backup\rman_test.txt' log 'e:\backup\test\log\%date:~0,4%_%date:~5,2%_%date:~8,2%.log'
