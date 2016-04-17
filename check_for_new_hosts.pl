#!/usr/bin/perl

#======================================
#Instructions to make this work for you
#======================================
#Update log and script paths as necessary
#Set up your credentials in /etc/msmtprc
#Update the EMAILADDRESS placeholders in the script below
# Note that e-mail addresses must be escaped, like: myEmail\+testing\@gmail.com or myEmail\@gmail.com
#======================================

#Which hosts do we know about? This file must be updated manually
$expectedHosts_input = "/home/scripts/expected_hosts.txt";

#This file will be udpated automatically
$nmapHosts_input = "/home/scripts/scriptLogs/working/nmap_hosts.txt";

#Log file
$logger = "/home/scripts/scriptLogs/host_logs.txt";

open (LOGGER, ">>$logger") or die $!;

$dateTime = `date`;
print LOGGER "------ $dateTime ------\n";
print LOGGER "Trying to read file: \'$expectedHosts_input\' into array...\n";
my @expected_hosts = do {
	open my $fh, "<", $expectedHosts_input
		or die "could not open $expectedHosts_input: $!";
	<$fh>;
};
#this saves the length of the array
$numExpectedHosts = scalar @expected_hosts;

#Create an array (@expected_hosts) containing just the MAC addresses from the expected_hosts file. 
#The value is set to everything after the first comma (,)
for (my $i=0; $i < $numExpectedHosts; $i++) {
	@expected_hosts[$i]=substr(@expected_hosts[$i],index(@expected_hosts[$i], ",")+1);
}

#print "Printing expected MAC values:\n";
#This just prints the MAC addresses that are allowed on the network
#for (my $i=0; $i < $numExpectedHosts; $i++) {
#	print "Value $i: @expected_hosts[$i]";
#}

print LOGGER "Running nmap to discover hosts...\n";
$nmapCommand = "/usr/bin/nmap -sP 192.168.1.1/24";
$nmapOutput = `$nmapCommand`;

#Grep the output from nmap to find lines that contain MAC addresses
#This variable contains multiple lines
$filteredNmapOutput = `echo "$nmapOutput" | grep "MAC Address"`;

#Remove everything from each line except the MAC address
#This variable contains multiple lines
$filteredNmapOutput = `echo "$filteredNmapOutput" | sed 's/MAC Address:\ //g' | sed 's/\ (.*)//g'`;

#Split the filtered nmap output by new lines. The new array stores one MAC address per index
@nmap_hosts = split /\n/, $filteredNmapOutput;

#Total number of nmap MAC addresses found. MAC addresses can be repeated within the array, so this is not the total number of UNIQUE MAC addresses found
$numNmapHosts = scalar @nmap_hosts;

#Ensure MAC address is correct size. This is done to remove newlines, specifically.
for (my $i=0; $i < $numNmapHosts; $i++){
	@nmap_hosts[$i] = lc substr(@nmap_hosts[$i],0,17);
}

for (my $i=0; $i < $numExpectedHosts; $i++){
	@expected_hosts[$i] = lc substr(@expected_hosts[$i],0,17);
}

print LOGGER "$numNmapHosts hosts found on network:\n";

#Print each of the MAC addresses found by nmap
#for (my $i=0; $i < $numNmapHosts; $i++) {
#	print "Host found: @nmap_hosts[$i]\n";
#}   

#Compare @nmap_hosts with @expected_hosts to determine if any MAC addresses were found by nmap that were not expected
#This variable is used since arrays seem to be initialized with a size of 1, so checking if @new_hosts ==0 is not a reliable test to see if we found a new host or not.
$New_Host_Found="false";
for (my $i=0; $i < $numNmapHosts; $i++) {
$found="false";
	for (my $p=0; $p < $numExpectedHosts; $p++) {
#		print "Comparing: @nmap_hosts[$i] with @expected_hosts[$p].\n";
		if (@nmap_hosts[$i] eq @expected_hosts[$p]){
			print LOGGER "@nmap_hosts[$i] was found and expected.\n";
			#remove any hosts we were expecting from @nmap_hosts
			@nmap_hosts[$i] = "";
			$found = "true";
			break;
		}
	}
	if ($found eq "false"){
		#if the host was unexpected, nothing to do since we take care of it in the above conditional
		$New_Host_Found="true";
		print LOGGER "@nmap_hosts[$i] was found, but not expected.\n";
	}
}

if ($New_Host_Found eq "true"){
	print LOGGER "New hosts: \n";
	@new_hosts = {};
#	$temp_array_size = scalar @new_hosts;
#	print LOGGER "new_hosts array initialized.. size: $temp_array_size";
	$counter = 0;
	for (my $i=0; $i < $numNmapHosts; $i++) {
		if (@nmap_hosts[$i] ne "") {
			#Stored as upper case
			@new_hosts[$counter] = uc @nmap_hosts[$i];
			$counter++;
			print LOGGER "$nmap_hosts[$i]\n";	
		}
	}

	$numNewHosts = scalar @new_hosts;
#	print LOGGER "About to check numNewHosts size.. size=$numNewHosts";
	#If we found hosts we weren't expecting
	if ($numNewHosts > 0) {
		$emailBody = "";
		$grepPattern = "";
	
		#We need this variable to handle the last host, since it should not have '\\|' after it
		$lastHost = "@new_hosts[$numNewHosts-1]";

		for (my $i=0; $i < $numNewHosts - 1; $i++){
			#This pattern allows us to grep for multiple strings at once
			$grepPattern = "$grepPattern@new_hosts[$i]\\|";
		}
		#Add on the last host to the pattern
		$grepPattern = "$grepPattern$lastHost";

	#	print "grep pattern: $grepPattern\n";

		#We'll e-mail ourselves the output of the grep. '-B 1' means to include the line before any found greps.. in this case, that'll be the IP address of the host
		$emailBody = `echo "$nmapOutput" | grep -B 1 "$grepPattern"`;

	#	print "E-mail:\n";
	#	print "$emailBody";
	
		open (MYFILE, '>>email.txt') or die $!;

	#e-mail addresses must be escaped, like: myEmail\+testing\@gmail.com
		print MYFILE "date: `date +%Y-%m-%d`\n";	
		print MYFILE "to: EMAILADDRESS\n";
		print MYFILE "subject: New Host on Your Network!\n";
		print MYFILE "From: EMAILADDRESS\n";
		print MYFILE "$numNewHosts new hosts found! $numNmapHosts total hosts found.\n";
		print MYFILE "New Host Info:\n";
		print MYFILE "$emailBody";

		close (MYFILE);

		#Send the e-mail
		#Credentials from /etc/msmtprc
		$emailSent = `/usr/sbin/sendmail EMAILADDRESS <email.txt`;

		print LOGGER "E-mail Sent!\n";

	#	print `cat email.txt`;
	#	print "\n";

		#Delete the e-mail file -- we'll create it on each run
		$tempVar = `rm -rf email.txt`;


	}
	else {
		print LOGGER "No new hosts found!\n";
		#I don't think this will ever be reached
	}
}
else {
	print LOGGER "No new hosts found!\n";
}
print LOGGER "Done.\n";

$dateTime = `date`;
print LOGGER "------ $dateTime ------\n";

