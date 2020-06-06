#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.
#
# Title: setup-ambari-server.sh
# Author: WKD
# Date: 190406
# Note: It is important to change the name of the Ambari database when configuring
# to use postgres to support both HDF and HDP.

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt
[[ "TRACE" ]] && set -x

# VARIABLES
FLAG=/var/log/setup-ambari-server.log
: ${AMBARI_DB_HOSTNAME:="db01.cloudair.lan"}
: ${AMBARI_DB_PORT:=5432}
: ${AMBARI_DB_NAME:="ambari"}
: ${AMBARI_DB_USER:="ambari"}
: ${AMBARI_DB_PASSWORD:=BadPass%1}

# FUNCTIONS
function debug() {
  [[ "DEBUG" ]]  && echo "[DEBUG] $@" 1>&2
}

function checkVar() {
# Validate variables 

	if [[ -z "${AMBARI_DB_PASSWORD}" ]]; then
  		MY_SCRIPT_VARIABLE="Some default value because ENV is undefined"
	else
  		MY_SCRIPT_VARIABLE="${AMBARI_DB_PASSWORD}"
	fi
	echo ${MY_SCRIPT_VARIABLE} > /root/servervartest.txt
}

function waitForDB() {
# Ensure DB is running

  	while : ; do
    		PGPASSWORD=${AMBARI_DB_PASSWORD} psql -h ${AMBARI_DB_HOSTNAME} -d ${AMBARI_DB_NAME} -U ${AMBARI_DB_USER} -c "select 1"
    		[[ $? == 0 ]] && break
    		sleep 5
  	done
}

function configRemoteAmbari() {
# Configure remote ambari

  	if [ -z "${AMBARI_DB_HOSTNAME}" ]; then
    		ambari-server setup --silent --java-home ${JAVA_HOME} --jdbc-db=postgres --jdbc-driver=/usr/share/java/postgresql-jdbc.jar
  	else
    		# Configure remote jdbc connection
    		ambari-server setup --silent --jdbc-db=postgres --jdbc-driver=/usr/share/java/postgresql-jdbc.jar
    		# Configure remote ambari
    		ambari-server setup \
			--silent \
			--java-home ${JAVA_HOME} \
			--database postgres \
			--databasehost ${AMBARI_DB_HOSTNAME} \
			--databaseport ${AMBARI_DB_PORT} \
			--databasename ${AMBARI_DB_NAME} \
 			--databaseusername ${AMBARI_DB_USER} \
			--databasepassword ${AMBARI_DB_PASSWORD} \
        		--postgresschema ambari 
    		waitForDB
    		PGPASSWORD=${AMBARI_DB_PASSWORD} psql -h ${AMBARI_DB_HOSTNAME} -d ${AMBARI_DB_NAME} -U ${AMBARI_DB_USER}  < /var/lib/ambari-server/resources/Ambari-DDL-Postgres-CREATE.sql
  	fi
}

function main() {
# Run one time only

  	if [ ! -f ${FLAG} ]; then
    		configRemoteAmbari
  	fi

  	echo "Setup Ambari server on $(date +%Y-%m-%d:%H:%M:%S)" >> ${FLAG}
}

# MAIN
checkVar
main "$@"
