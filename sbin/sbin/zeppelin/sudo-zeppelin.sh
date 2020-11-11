#!/bin/bash

# This script is for training purposes only and is to be used only
# in support of approved training. The author assumes no liability
# for use outside of a training environments. Unless required by
# applicable law or agreed to in writing, software distributed under
# the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES
# OR CONDITIONS OF ANY KIND, either express or implied.

# Title: sudo-zeppelin.sh
# Author: WKD
# Date: 1NOV19
# Purpose: This script grants sudo without a password access to the 
# user zeppelin. 

# DEBUG
#set -x
#set -eu
#set >> /root/setvar.txt

# VARIABLE
NUMARGS=$#
DIR=${HOME}
DATETIME=$(date +%Y%m%d%H%M)
LOGFILE=${DIR}/log/sudo-zeppelin.log

# FUNCTIONS
function usage() {
        echo "Usage: $(basename $0)"
        exit 
}

function callInclude() {
# Test for script and run functions

        if [ -f ${DIR}/sbin/include.sh ]; then
                source ${DIR}/sbin//include.sh
        else
                echo "ERROR: The file ${DIR}/sbin/include.sh not found."
                echo "This required file provides supporting functions."
		exit 1
        fi
}

function sudoZeppelin() {

	sudo usermod -aG wheel zeppelin 
}

# MAIN
# Source Functions
#callInclude

# Run checks
#checkSudo
#checkArg 0

# Sudo Zeppelin
sudoZeppelin
