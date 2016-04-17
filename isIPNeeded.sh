#!/bin/bash

#======================================
#Instructions to make this work for you
#======================================
#Update the URL placeholder on line 26
#Put something at that URL that will respond with 'no'
#When you want your IP address sent to you, update that response to anything else
#======================================

SCRIPTNAME=`readlink -f $0`
CURRENTDIR=`dirname $SCRIPTNAME`
LOGFILE=$CURRENTDIR/IPlog.log
cd $CURRENTDIR

if [ ! -f $LOGFILE ]; then
	touch $LOGFILE
fi

echo "Date: `date`" >> $LOGFILE
echo "Checking conditions..." >> $LOGFILE

CURRENTIP=`curl ifconfig.me`
echo "Current IP: $CURRENTIP" >> $LOGFILE

RESPONSE=`curl URL` 
echo "Response from test: $RESPONSE" >> $LOGFILE

if [ $CURRENTIP != `cat currentIP.txt` ]; then
	echo "IP changed from `cat currentIP.txt`. Sending e-mail.." >> $LOGFILE
	./emailIP.sh
elif [ $RESPONSE != 'no' ]; then
	echo "IP did not change but user requested IP reminder. Sending e-mail.." >> $LOGFILE
	./emailIP.sh
else
	echo "IP did not change and user did not request IP reminder." >> $LOGFILE
fi

echo "" >> $LOGFILE
