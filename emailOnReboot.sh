
#!/bin/bash

#======================================
#Instructions to make this work for you
#======================================
#Set up your credentials in /etc/msmtprc
# See this script for help doing that: https://gist.github.com/kevinfealey/f4300202b5e0d1b6f8150eb9b9d6bcb2
#Update the TOEMAIL and FROMEMAIL variables in the script below
#======================================

# This file is executed from /etc/init.d/emailOnReboot [start/stop]

SCRIPTNAME=`readlink -f $0`
CURRENTDIR=`dirname $SCRIPTNAME`
TOEMAIL=""
FROMEMAIL=""

bootStatus=$1
myIP=`ifconfig | grep -A 8 -e enp3s0f0`
myHostname=`hostname -f`

echo "$SCRIPTNAME called with parameter '$bootStatus'"
#credentials from /etc/msmtprc
mail -vs "$myHostname has $bootStatus!" $TOEMAIL <<__EOF
Server ifconfig returned:
$myIP
Server hostname is: $myHostname
Server uptime: `uptime`
__EOF
