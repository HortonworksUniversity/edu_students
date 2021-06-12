#!/bin/bash
database_name=tpcds_kudu_10
current_path=`pwd`
queries_dir=${current_path}/queries
rm -rf logs
mkdir logs
for t in `ls ${queries_dir}`
do
    echo "current query will be ${queries_dir}/${t}"
    beeline  -n username -p password -u jdbc:hive2://localhost:21050/${tpcds_bin_partitioned_parquet_10} -f  ${queries_dir}/${t} &>logs/${t}.log
done
