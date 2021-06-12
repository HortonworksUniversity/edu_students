#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: run-stream.sh
# Author: WKD
# Date: 12JUN21 
# Purpose: Script to run streaming. This is dependent upon creating
# a number of sql scripts and then running them in a loop. Recommend
# working with the Cloudmart dataset and using the tpcds query 
# generation tool to create the sql queries

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES
NUMARGS=$#
DIR=${HOME}
DB_HOSTNAME=db01.cloudair.lan
DB_PORT=5432
DB_NAME=cloudmart
DB_USER=devuser
PGPASSWORD=BadPass%1
QUERY_DIR=/var/query/cloudmart
OPTION=$1
INPUT=$2
OUTPUT=$3
DATETIME=$(date +%Y%m%d%H%M)
LOGFILE=${DIR}/log/run-stream.log

# FUNCTIONS
function usage() {
	echo "Usage: $(basename $0) [push <path/file> <path/file>]" 
        echo "                          [extract <path/tar-file> <path>]"
        echo "                          [run <path/remote_script>]"
        echo "                          [delete <path/file_name>]"
        echo "                          [repo <file_name>  <path>]"
	exit 
}

function callInclude() {
# Test for script and run functions

        if [ -f ${DIR}/sbin/include.sh ]; then
                source ${DIR}/sbin/include.sh
        else
                echo "ERROR: The file ${DIR}/sbin/include.sh not found."
                echo "This required file provides supporting functions."
		exit 1
        fi
}

function pushFile() {
# push a file into remote node

	FILE=${INPUT}
	OUTPUT=${OUTPUT}

	checkFile ${FILE}

        for HOST in $(cat ${HOSTS}); do
                scp -r ${FILE} ${HOST}:${OUTPUT} >> ${LOGFILE} 2>&1
		RESULT=$?
		if [ ${RESULT} -eq 0 ]; then
                	echo "Push ${FILE} to ${HOST}" | tee -a ${LOGFILE}
		else
                	echo "ERROR: Failed to push ${FILE} to ${HOST}" | tee -a ${LOGFILE}
		fi
        done
}

function runQuery() {

	psql -h ${DB_HOSTNAME} -d ${DB_NAME} -U ${DB_USER} -f ${QUERY_DIR}/query_0.sql

}

function runOption() {
# Case statement for options

	case "${OPTION}" in
		-h | --help)
			usage
			;;
  		push)
                        checkArg 3
                        pushFile
			;;
                extract)
                        checkArg 3
                        runTar
			;;
                run)
                        checkArg 2
                        runScript
			;;
                delete)
                        checkArg 2
                        deleteFile
			;;
                repo)
                        checkArg 3
                        pushRepo
			;;
		*)
			usage
			;;
	esac
}

# MAIN

runQuery

# Source functions
#callInclude

# Run checks
#checkSudo

# Run setups
#setupLog ${LOGFILE}

# Run option
#runOption

# Review log file
#echo "Review log file at ${LOGFILE}"
