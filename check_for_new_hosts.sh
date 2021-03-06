#!/bin/bash

#======================================
#Instructions to make this work for you
#======================================
#Update log and script paths as necessary
#Set up your credentials in /etc/msmtprc
#Update the IP range checked by nmap as necessary
#Update the EMAILADDRESS placeholders in the script below
#======================================

#Generated by nmap
nmapHosts="/home/scripts/scriptLogs/working/nmap_hosts.txt"

#Generated manually by me
expectedHosts="/home/scripts/expected_hosts.txt"

expectedMACs="/home/scripts/scriptLogs/working/expectedMACs.txt"
nmapMACs="/home/scripts/scriptLogs/working/nmapMACs.txt"

newHosts="/home/scripts/scriptLogs/working/newHost.txt"

#Log file
logger="/home/scripts/scriptLogs/host_logs.txt"
eMail="/home/scripts/scriptLogs/working/host_email.txt"

#Initiate Logging
echo "Beginning search for new hosts..." >> $logger
echo "------ `date` ------" >> $logger

#Get current hosts
echo "Running nmap to discover hosts" >> $logger
##Update this IP range based on your network range
nmap -sP 192.168.1.1/24 > $nmapHosts
echo "Finished running nmap" >> $logger

#Parse and store MAC addresses
echo "Parsing MAC Addresses" >> $logger

echo "Storing nmap MACs" >> $logger
cat $nmapHosts | grep "MAC Address" | sed 's/MAC Address:\ //g' | sed 's/\ (.*)//g' | sort -bd > $nmapMACs

echo "Storing expected MACs" >> $logger
cat $expectedHosts | sed 's/^.*,//g' | sort -bd > $expectedMACs

echo "Diff actual vs expected MACs" >> $logger
MAC_difference=`diff -wi $expectedMACs $nmapMACs | grep '>' | sed 's/>\ //g'`
echo "MAC Difference: $MAC_difference" >> $logger

if [ "$MAC_difference" ]; then
#echo "Inside conditional" >> $logger
 #get hostname and IP address
 #This splits the new MAC addresses into an array in case there is more than one
 #Internal field separator (a built in object)	
 OIFS=$IFS
 IFS=$'\n'
 Array=("${Array[@]}" "$MAC_difference")
 echo "Array Length: ${#Array[@]}"
 for i in "${Array[@]}";
 do 
 	hostInfo="`cat $nmapHosts | grep -B 1 "$i"`"
#	echo "HostInfo: $hostInfo" >> $logger
 done
 IFS=$OIFS
 echo "New Host Found!" >> $logger
 echo "$hostInfo" >> $logger
	
 #populate e-mail object
 echo "date: `date +%Y-%m-%d`" > $eMail
 echo "to: EMAILADDRESS" >> $eMail
 echo "subject: New Host on Your Network!" >> $eMail
 echo "from: EMAILADDRESS" >> $eMail
 echo "" >> $eMail
 echo "New Host Found:" >> $eMail
 echo "$hostInfo" >> $eMail

 #Send the e-mail
 #Credentials from /etc/msmtprc
 /usr/sbin/sendmail EMAILADDRESS < $eMail
 echo "E-mail sent!" >> logger
else
 echo "No new hosts found" >> $logger
fi

echo "Host check complete!" >> $logger
echo "------ `date` ------" >> $logger
echo " " >> $logger
echo " " >> $logger


