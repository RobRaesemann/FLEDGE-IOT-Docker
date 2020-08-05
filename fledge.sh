#!/bin/bash
service rsyslog start
/usr/local/fledge/bin/fledge start
tail -f /var/log/syslog