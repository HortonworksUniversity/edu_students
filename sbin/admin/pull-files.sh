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

function getCM() {
# Pull down and setup CM tarfile

	wget https://abed8166-1467-426d-bf32-7f9a066f7417:5d07569c1aa0@archive.cloudera.com/p/cm7/${CM_VER}/repo-as-tarball/cm${CM_VER}-redhat7.tar.gz 
}

function getCDP() {
# Pull down CDH parcels

	wget --recursive --no-parent --no-host-directories https://abed8166-1467-426d-bf32-7f9a066f7417:5d07569c1aa0@archive.cloudera.com/p/cdh7/${CDP_VER}/parcels
}

function getCDF() {
# Pull down CDF manifest, parcel, and sha

	wget --recursive --no-parent --no-host-directories https://abed8166-1467-426d-bf32-7f9a066f7417:5d07569c1aa0@archive.cloudera.com/p/cfm2/2.1.1.0/redhat7/yum/tars/parcel/manifest.json 
	wget --recursive --no-parent --no-host-directories https://abed8166-1467-426d-bf32-7f9a066f7417:5d07569c1aa0@archive.cloudera.com/p/cfm2/2.1.1.0/redhat7/yum/tars/parcel/CFM-2.1.1.0-13-el7.parcel 
	wget --recursive --no-parent --no-host-directories https://abed8166-1467-426d-bf32-7f9a066f7417:5d07569c1aa0@archive.cloudera.com/p/cfm2/2.1.1.0/redhat7/yum/tars/parcel/CFM-2.1.1.0-13-el7.parcel.sha
}


function getCSD() {
# Pull down CSD files for NiFi and NiFi registry.

	wget --recursive --no-parent --no-host-directories https://abed8166-1467-426d-bf32-7f9a066f7417:5d07569c1aa0@archive.cloudera.com/p/cfm2/2.1.1.0/redhat7/yum/tars/parcel/NIFI-1.13.2.2.1.1.0-13.jar
	wget --recursive --no-parent --no-host-directories https://abed8166-1467-426d-bf32-7f9a066f7417:5d07569c1aa0@archive.cloudera.com/p/cfm2/2.1.1.0/redhat7/yum/tars/parcel/NIFIREGISTRY-0.8.0.2.1.1.0-13.jar
}

# Main
checkArg 2 
getCM
getCDP
getCDF
getCSD
