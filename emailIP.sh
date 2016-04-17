#!/bin/bash

#======================================
#Instructions to make this work for you
#======================================
#Update log and script paths as necessary
#Set up your credentials in /etc/msmtprc
#Update the EMAILADDRESS placeholders in the script below
#======================================

SCRIPTNAME=`readlink -f $0`
CURRENTDIR=`dirname $SCRIPTNAME`
LOGFILE=$CURRENTDIR/scriptLogs/IPlog.log
MAILFILE=$CURRENTDIR/scriptLogs/mail.txt

myIP=`curl ifconfig.me`

# Build mail formatted file
echo "date: `date +%Y-%m-%d`" > $MAILFILE
echo "to: EMAILADDRESS" >> $MAILFILE
echo "subject: Your IP!" >> $MAILFILE
echo "from: EMAILADDRESS" >> $MAILFILE
echo "" >> $MAILFILE
echo "Your IP address is: $myIP" >> $MAILFILE

echo $myIP > currentIP.txt

echo "E-mail content:" >> $LOGFILE
echo `cat $MAILFILE` >> $LOGFILE

# Send the email
# Credentials from /etc/msmtprc
/usr/sbin/sendmail EMAILADDRESS < $MAILFILE

echo "E-mail sent." >> $LOGFILE
echo "Deleting $MAILFILE" >> $LOGFILE
rm -rf $MAILFILE

echo "" >> $LOGFILE
