#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.
# IMPORTANT ENSURE JAVA_DIR and PATH are set for root

# Title: setup-local-repo.sh
# Author: WKD
# Date: 210601
# Purpose: This script installs a local repository in support of
# Cloudera Manager and Cloudera Runtime. This script should be run 
# on the host supporting the local repository. 

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLES
NUMARGS=$#
DIR=${HOME}
CM_VER=$1
CDP_VER=$2
DATETIME=$(date +%Y%m%d%H%M)
LOGFILE=${DIR}/log/setup-local-repo.log

# FUNCTIONS
function usage() {
        echo "Usage: $(basename $0) [cm_version_number] [cdp_version_number]"
        echo "Example: $(basename $0) 7.2.4 7.1.5.0"
        exit 1
}

function checkArg() {
# Check if arguments exits

        if [ ${NUMARGS} -ne "$1" ]; then
                usage
        fi
}

function checkFile() {
# Check for a file

        FILE=$1
        if [ ! -f ${FILE} ]; then
                echo "ERROR: Input file ${FILE} not found"
                usage
        fi
}

function installHTTP() {
# Install http server

	if [ ! -d /var/www/html ]; then
		sudo yum install -y httpd
		sudo sed -i -e 's/Listen 80/Listen 8060/g' /etc/httpd/conf/httpd.conf
        	sudo systemctl enable httpd
        	sudo systemctl start httpd
   		sudo systemctl status httpd	
	fi
}

function makeDir() {
# Create Cloudera repos directory

	if [ ! -d /var/www/html/cloudera-repos ]; then
		sudo mkdir -p /var/www/html/cloudera-repos/cm7/${CM_VER}
		sudo mkdir -p /var/www/html/cloudera-repos/cdh7
		sudo mkdir -p /var/www/html/cloudera-repos/cdh2
	fi
}

function getCM() {
# Pull down and setup CM tarfile

	sudo wget https://[username]:[password]@archive.cloudera.com/p/cm7/${CM_VER}/repo-as-tarball/cm${CM_VER}-redhat7.tar.gz 
	sudo tar xvfz cm${CM_VER}-redhat7.tar.gz -C /var/www/html/cloudera-repos/cm7 --strip-components=1
	sudo chmod -R ugo+rX /var/www/html/cloudera-repos/cm7
}

function getCDP() {
# Pull down CDH parcels

	sudo wget --recursive --no-parent --no-host-directories https://[username]:[password]@archive.cloudera.com/p/cdh7/${CDP_VER}/parcels -P /var/www/html/cloudera-repos
	sudo chmod -R ugo+rX /var/www/html/cloudera-repos/cdh7
}

function getCDF() {
# Pull down CDF manifest, parcel, and sha

	sudo wget --recursive --no-parent --no-host-directories https://[username]:[password]@archive.cloudera.com/p/cfm2/2.1.1.0/redhat7/yum/tars/parcel/manifest.json 
	sudo wget --recursive --no-parent --no-host-directories https://[username]:[password]@archive.cloudera.com/p/cfm2/2.1.1.0/redhat7/yum/tars/parcel/CFM-2.1.1.0-13-el7.parcel 
	sudo wget --recursive --no-parent --no-host-directories https://[username]:[password]@archive.cloudera.com/p/cfm2/2.1.1.0/redhat7/yum/tars/parcel/CFM-2.1.1.0-13-el7.parcel.sha
	sudo chmod -R ugo+rX /var/www/html/cloudera-repos/cdh7
}

function getCSD() {
# The CSD files are need by Cloudera Manager to install the services. 
# They are jar files to be placed into /opt/cloudera/csd on the CM host.

	wget --recursive --no-parent --no-host-directories https://[username]:[password]@archive.cloudera.com/p/cfm2/2.1.1.0/redhat7/yum/tars/parcel/NIFI-1.13.2.2.1.1.0-13.jar
	wget --recursive --no-parent --no-host-directories https://[username]:[password]@archive.cloudera.com/p/cfm2/2.1.1.0/redhat7/yum/tars/parcel/NIFIREGISTRY-0.8.0.2.1.1.0-13.jar
}

function workAround() {
# This is used for exercise purposes to avoid large Downloads across the Internet

# Move CM 
	sudo tar xvfz ${HOME}/Downloads/cm${CM_VER}-redhat7.tar.gz -C /var/www/html/cloudera-repos/cm7/7.2.4 --strip-components=1

# Move CDP parcels
	sudo rm -r /var/www/html/cloudera-repos/cdh7
	sudo mv ${HOME}/Downloads/cdh7 /var/www/html/cloudera-repos

# Move CSD jar files
	mv ${HOME}/Downloads/p/cfm2/2.1.1.0/redhat7/yum/tars/parcel/NIFI*jar ${HOME}/Downloads 
	scp -o "ForwardAgent yes" ${HOME}/Downloads/NIFI*jar sysadmin@admin01.cloudair.lan:/tmp
	ssh -o StrictHostKeyChecking=no -tt admin01.cloudair.lan "sudo mv /tmp/NIFI*jar /opt/cloudera/csd/" 
	 ssh -o StrictHostKeyChecking=no -tt admin01.cloudair.lan "sudo chown cloudera-scm:cloudera-scm /opt/cloudera/csd/NIFI*jar"
 	ssh -o StrictHostKeyChecking=no -tt admin01.cloudair.lan "sudo chmod 644 /opt/cloudera/csd/NIFI*jar"
 	ssh -o StrictHostKeyChecking=no -tt admin01.cloudair.lan "sudo systemctl restart cloudera-scm-server"

# Move CDF parcels
	sudo rm -r /var/www/html/cloudera-repos/cdf2
	sudo mv ${HOME}/Downloads/cdf2 /var/www/html/cloudera-repos


# Set permissions
	sudo chmod -R ugo+rX /var/www/html/cloudera-repos
}

function restartHTTP() {
# Restart the HTTP service

	sudo systemctl restart httpd
}

function checkRepo() {

	echo "Now test the repo by using a browser"
	echo "http://infra.cloudair.lan:8060"
}

# Main
checkArg 2 
installHTTP
makeDir
#getCM
#getCDP
#getCDF
#getCSD
workAround
restartHTTP
checkRepo
