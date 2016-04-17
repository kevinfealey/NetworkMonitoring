#!/bin/bash

#======================================
#Instructions to make this work for you
#======================================
#Update log and script paths as necessary
#Set up your credentials in /etc/msmtprc
#Update the EMAILADDRESS placeholders in the script below
#======================================

# This file is executed from /etc/init.d/rebootNotify [start/stop]

SCRIPTNAME=`readlink -f $0`
CURRENTDIR=`dirname $SCRIPTNAME`
LOGFILE=$CURRENTDIR/scriptLogs/emailOnReboot.log
MAILFILE=$CURRENTDIR/scriptLogs/rebootMail.txt

bootStatus=$1
myIP=`hostname -i`
myHostname=`hostname -f`

echo "$SCRIPTNAME called with parameter '$bootStatus'"

# Build mail formatted file
echo "date: `date +%Y-%m-%d`" > $MAILFILE
echo "to: EMAILADDRESS" >> $MAILFILE
echo "subject: Your Box Has $bootStatus!" >> $MAILFILE
echo "from: EMAILADDRESS" >> $MAILFILE
echo "" >> $MAILFILE
echo "Server internal IP address is: $myIP" >> $MAILFILE
echo "Server hostname is: $myHostname" >> $MAILFILE
echo "Server uptime: `uptime`" >> $MAILFILE

echo "E-mail content:" >> $LOGFILE
echo `cat $MAILFILE` >> $LOGFILE

# Send the email
# Credentials from /etc/msmtprc
/usr/sbin/sendmail EMAILADDRESS < $MAILFILE

echo "E-mail sent." >> $LOGFILE
echo "Deleting $MAILFILE" >> $LOGFILE
rm -rf $MAILFILE

echo "" >> $LOGFILE
