#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: setup-ambari-user.sh
# Author: WKD
# Date: 26NOV18
# Purpose: This script sets the hdfs hooks for Ambari and then creates
# two users, sysadmin and devuser, in Ambari DB. This is a good example
# of using the Ambari REST api.

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES
NUMARGS=$#
DIR=${HOME}
OPTION=$1
AMBARI_HOST=admin01.cloudair.lan
AMBARI_URL=http://admin01.cloudair.lan:8080
AMBARI_USER=admin
AMBARI_PASSWORD=admin
AMBARI_CLUSTER=cloudair
DATETIME=$(date +%Y%m%d%H%M)
LOGDIR=${DIR}/log
LOGFILE=${LOGDIR}/setup-ambari-users.log

# FUNCTIONS
function usage() {
        echo "Usage: $(basename $0)"
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

function addHooks() {
# Add hooks for Ambari to create directory in HDFS

	echo "ambari.post.user.creation.hook.enabled=true" | sudo tee -a /etc/ambari-server/conf/ambari.properties 
	echo "ambari.post.user.creation.hook=/var/lib/ambari-server/resources/scripts/post-user-creation-hook.sh" | sudo tee -a /etc/ambari-server/conf/ambari.properties 
	sudo ambari-server restart
}

function addUsers() {
# Create Ambari users sysadmin and devuser, then assign to groups and roles
# Permissions: CLUSTER.ADMINISTRATOR CLUSTER.OPERATOR SERVICE.ADMINISTRATOR SERVICE.OPERATOR CLUSTER.USER

	# Add users
        curl -i -u ${AMBARI_USER}:${AMBARI_PASSWORD} -H "X-Requested-By: ambari" -X POST -d '{"Users/user_name":"sysadmin","Users/password":"BadPass%1","Users/active":"true", "Users/admin":"true"}' ${AMBARI_URL}/api/v1/users
        curl -i -u ${AMBARI_USER}:${AMBARI_PASSWORD} -H "X-Requested-By: ambari" -X POST -d '{"Users/user_name":"devuser","Users/password":"BadPass%1","Users/active":"true", "Users/admin":"false"}' ${AMBARI_URL}/api/v1/users

	# Add groups
        curl -i -u ${AMBARI_USER}:${AMBARI_PASSWORD} -H "X-Requested-By: ambari" -X POST -d '[{"Groups":{"group_name":"admin"}}]", "Users/admin":"true"}' ${AMBARI_URL}/api/v1/groups
        curl -i -u ${AMBARI_USER}:${AMBARI_PASSWORD} -H "X-Requested-By: ambari" -X POST -d '[{"Groups":{"group_name":"dev"}}]", "Users/admin":"true"}' ${AMBARI_URL}/api/v1/groups

	# Add users to groups
        curl -i -u ${AMBARI_USER}:${AMBARI_PASSWORD} -H "X-Requested-By: ambari" -X POST -d '[{"MemberInfo":{"user_name":"sysadmin"}}]' ${AMBARI_URL}/api/v1/groups/admin/members
        curl -i -u ${AMBARI_USER}:${AMBARI_PASSWORD} -H "X-Requested-By: ambari" -X POST -d '[{"MemberInfo":{"user_name":"devuser"}}]' ${AMBARI_URL}/api/v1/groups/dev/members

	# Assign groups to roles
        curl -i -u ${AMBARI_USER}:${AMBARI_PASSWORD} -H "X-Requested-By: ambari" -X POST -d '[{"PrivilegeInfo":{"permission_name":"CLUSTER.ADMINISTRATOR","principal_name":"admin","principal_type":"GROUP"}}]' ${AMBARI_URL}/api/v1/clusters/${AMBARI_CLUSTER}/privileges
        curl -i -u ${AMBARI_USER}:${AMBARI_PASSWORD} -H "X-Requested-By: ambari" -X POST -d '[{"PrivilegeInfo":{"permission_name":"SERVICE.ADMINISTRATOR","principal_name":"dev","principal_type":"GROUP"}}]' ${AMBARI_URL}/api/v1/clusters/${AMBARI_CLUSTER}/privileges

	# Disable admin user
        #curl -i -u ${AMBARI_USER}:${AMBARI_PASSWORD} -H "X-Requested-By: ambari" -X POST -d '{"Users/active":"false"}' ${AMBARI_URL}/api/v1/users/admin
}

function deleteUser() {
# Delete user one at a time

 	curl --insecure -u ${AMBARI_USER}:${AMBARI_PASSWORD} -H "X-Requested-By: ambari" -X DELETE  ${AMBARI_URL}/api/v1/users/${USER}
}

function deleteGroup() {
# Delete user one at a time

 	curl --insecure -u ${AMBARI_USER}:${AMBARI_PASSWORD} -H "X-Requested-By: ambari" -X DELETE  ${AMBARI_URL}/api/v1/group/${GROUP}
}

function addData() {
# Add the data sets into hdfs:/data

	echo "Building data directories, please wait"
        sudo -u hdfs hdfs dfs -mkdir /data
        sudo -u hdfs hdfs dfs -put ${HOME}/data/book/ /data/
        sudo -u hdfs hdfs dfs -put ${HOME}/data/latin/ /data/
        sudo -u hdfs hdfs dfs -put ${HOME}/data/nyse/ /data/
        sudo -u hdfs hdfs dfs -chmod -R 777 /data
        hdfs dfs -ls /data
}

function runSetup() {
# Sets flag on first time run on boot up. Ensures this script is not run again.

        if [ ! -f ${LOGFILE} ]; then
                touch ${LOGFILE}
                echo "Starting setup of Ambari users" >> ${LOGFILE}
		addHooks >> ${LOGFILE}
		addUsers >> ${LOGFILE}
		addData >> ${LOGFILE}
                sudo echo "First setup of Ambari users is complete" >> ${LOGFILE}
        else
                sudo echo "Ambari users is already initialized" >> ${LOGFILE}
        fi
}

# MAIN
# Source functions
callInclude

# Run checks
checkArg 0 
checkSudo
checkLogDir

# Run option
runSetup
