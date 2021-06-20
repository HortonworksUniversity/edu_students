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
        echo "Example: $(basename $0) 7.1.3 7.1.2"
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
		echo "Install httpd"
		sudo yum install -y httpd
		sudo sed -i -e 's/80/8060/g' /etc/httpd/conf/httpd.conf
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
		sudo mkdir -p /var/www/html/cloudera-repos/cfm2
	fi
}

function repoCM() {
# Pull down and setup CM tarfile

	echo "Install CM repo"

	# Install repo from Cloudera paywall 
	#sudo wget https://[username]:[password]@archive.cloudera.com/p/cm7/${CM_VER}/repo-as-tarball/cm${CM_VER}-redhat7.tar.gz 
	#sudo tar xvfz cm${CM_VER}-redhat7.tar.gz -C /var/www/html/cloudera-repos/cm7 --strip-components=1

	# Edu work around
	sudo aws s3 cp s3://admin-public/cloudera-parcels/cm7/cm${CM_VER}-redhat7.tar.gz /var/www/html/cloudera-repos/cm7/${CM_VER}
	sudo tar xvfz /var/www/html/cloudera-repos/cm7/${CM_VER}/cm${CM_VER}-redhat7.tar.gz -C /var/www/html/cloudera-repos/cm7/${CM_VER} --strip-components=1
	sudo rm /var/www/html/cloudera-repos/cm7/${CM_VER}/cm${CM_VER}-redhat7.tar.gz

	sudo chmod -R ugo+rX /var/www/html/cloudera-repos/cm7
}

function repoCDP() {
# Pull down CDH parcels

	echo "Install CDP repo

	# Install repo from Cloudera paywall 
	#sudo wget --recursive --no-parent --no-host-directories https://[username]:[password]@archive.cloudera.com/p/cdh7/${CDP_VER}/parcels -P /var/www/html/cloudera-repos

	# Edu work around
	sudo aws s3 cp s3://admin-public/cloudera-parcels/${CDP_VER}/manifest.json /var/www/html/cloudera-repos/cdh7/${CDP_VER}/
	sudo aws s3 cp s3://admin-public/cloudera-parcels/${CDP_VER}/CDH-7.1.2-1.cdh7.1.2.p0.4253134-el7.parcel.sha /var/www/html/cloudera-repos/cdh7/${CDP_VER}/
	sudo aws s3 cp s3://admin-public/cloudera-parcels/${CDP_VER}/CDH-7.1.2-1.cdh7.1.2.p0.4253134-el7.parcel /var/www/html/cloudera-repos/cdh7/${CDP_VER}/

	sudo aws s3 cp s3://admin-public/cloudera-parcels/7.1.3/manifest.json /var/www/html/cloudera-repos/cdh7/7.1.3/
	sudo aws s3 cp s3://admin-public/cloudera-parcels/7.1.3/CDH-7.1.3-1.cdh7.1.3.p0.4992530-el7.parcel.sha /var/www/html/cloudera-repos/cdh7/7.1.3/
	sudo aws s3 cp s3://admin-public/cloudera-parcels/7.1.3/CDH-7.1.3-1.cdh7.1.3.p0.4992530-el7.parcel /var/www/html/cloudera-repos/cdh7/7.1.3/

	sudo chmod -R ugo+rX /var/www/html/cloudera-repos/cdh7
}

function repoCFM() {
# Pull down CFM manifest, parcel, and sha

	echo "Install CFM repo"

	# Install repo from Cloudera paywall 
	#sudo wget --recursive --no-parent --no-host-directories https://[username]:[password]@archive.cloudera.com/p/cfm2/2.1.1.0/redhat7/yum/tars/parcel/manifest.json 
	#sudo wget --recursive --no-parent --no-host-directories https://[username]:[password]@archive.cloudera.com/p/cfm2/2.1.1.0/redhat7/yum/tars/parcel/CFM-2.1.1.0-13-el7.parcel 
	#sudo wget --recursive --no-parent --no-host-directories https://[username]:[password]@archive.cloudera.com/p/cfm2/2.1.1.0/redhat7/yum/tars/parcel/CFM-2.1.1.0-13-el7.parcel.sha

	# Edu work around
	sudo aws s3 cp s3://admin-public/cloudera-parcels/CFM/manifest.json /var/www/html/cloudera-repos/cfm2/2.0.1/
	sudo aws s3 cp s3://admin-public/cloudera-parcels/CFM/CFM-2.0.1.0-71-el7.parcel.sha /var/www/html/cloudera-repos/cfm2/2.0.1/
	sudo aws s3 cp s3://admin-public/cloudera-parcels/CFM/CFM-2.0.1.0-71-el7.parcel /var/www/html/cloudera-repos/cfm2/2.0.1/

	sudo chmod -R ugo+rX /var/www/html/cloudera-repos/cfm2
}

function repoCSD() {
# The CSD files are need by Cloudera Manager to install the services. 
# They are jar files to be placed into /opt/cloudera/csd on the CM host.

	echo "Install CSD repo in support of CFM, if required"
	#wget --recursive --no-parent --no-host-directories https://[username]:[password]@archive.cloudera.com/p/cfm2/2.1.1.0/redhat7/yum/tars/parcel/NIFI-1.13.2.2.1.1.0-13.jar
	#wget --recursive --no-parent --no-host-directories https://[username]:[password]@archive.cloudera.com/p/cfm2/2.1.1.0/redhat7/yum/tars/parcel/NIFIREGISTRY-0.8.0.2.1.1.0-13.jar
}

function restartHTTP() {
# Restart the HTTP service

	sudo systemctl restart httpd
}

function checkRepo() {

	echo "Now test the repo by using a browser"
	echo "http://worker03:8060/cloudera-repos"
}

# Main
checkArg 2 
installHTTP
makeDir
repoCM
repoCDP
repoCFM
#repoCSD
restartHTTP
checkRepo
