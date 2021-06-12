#!/usr/bin/env python
import os
 
with open("/var/tpcds-kit/tools/tpcds.sql") as ddl:
  for line in ddl:
    if line.startswith('--'):
      continue
    if line.startswith('create table'):
      table = line.replace("\n","").split(" ")[2]
      print("bulk insert %s from 'G:\%s' with (fieldterminator='|',rowterminator='0x0a',batchsize=1000);" %(table,table))
