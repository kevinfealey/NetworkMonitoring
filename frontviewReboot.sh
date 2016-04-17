#!/bin/bash

killall apache-ssl
/usr/sbin/apache-ssl -f /etc/frontview/apache/httpd.conf
