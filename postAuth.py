import smtplib
from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText

def post_auth(authcred, attributes, authret, info):

	fromaddr = ''
	toaddrs  = ''
	msg = MIMEMultipart()
	msg['From'] = fromaddr
	msg['To'] = toaddrs
	msg['Subject'] = 'User ' + authcred['username'] + ' authenticated to openvpn!'
	body = "User: " + authcred['username'] + " successfully authenticated to openvpnas.\r\n"
	if 'client_ip_addr' in authcred:	
		body += "IP: " + authcred['client_ip_addr'] + "\r\n" 
	else:
		body += "No IP address detected \r\n"

	if 'vpn_auth' in attributes:
		if (['vpn_auth']):
			body += "VPN Authentication \r\n"
			body += "Platform: " + attributes['client_info']['IV_PLAT'] + "\r\n"
		else:
			body += "Non-VPN authentication - probably to web view \r\n"
	else:
		body += "Authentication method not defined. Probably to web view \r\n"
	
	if 'client_hw_addr' in authcred:
		body += "Client MAC address: " + authcred['client_hw_addr'] + "\r\n"

	if 'reauth' in attributes:
		body += "This is a reauthentication: " + str(attributes['reauth']) + "\r\n"

	msg.attach(MIMEText(body, 'plain'))

	# Credentials (if needed)
	username = ''
	password = ''

	# The actual mail send
	server = smtplib.SMTP('smtp.gmail.com:587')
	server.starttls()
	server.login(username,password)
	text = msg.as_string()
	server.sendmail(fromaddr, toaddrs, text)
	server.quit()

	return authret
