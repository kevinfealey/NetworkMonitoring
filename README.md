# NetworkMonitoring#
This is a group of utilities I use on my home network to monitor various activities and perform specific actions

##check_for_new_hosts.pl##
Runs nmap on a specified IP range and compares any hosts found to a known whitelist (expected_hosts.txt). If any additional hosts are detected, an email is sent to a specified IP address.

##check_for_new_hosts.sh## 
Was replaced by the perl version above. This version probably works, but hasn't been used in a long time.

##emailIP.sh## 
Retrieves the current external-facing IP address from the host running the script, then e-mails the IP address to a specified address. Thiss script is utilized by the other scripts in this repository.

##emailOnReboot.sh## 
When used with init.d/rebootNotify, this file will send an email any time the box it is on [re]boots. 

##expected_hosts_example.txt## 
Should be renamed to expected_hosts.txt and is used by check_for_new_hosts.sh

##frontviewReboot.sh## 
Is designed to bring down a running apache server, then bring it back online with the specified server configuration. This script was designed to restart the frontview application of the Netgear ReadyNas.

##isIPNeeded.sh##
Works with emailIP.sh to send an email alert when the host's external IP address has changed. This script will also poll a particular URL (if run as a cronjob) to determine if the current IP address should be emailed, regardless of if it has changed.