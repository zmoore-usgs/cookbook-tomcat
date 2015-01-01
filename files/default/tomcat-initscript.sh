#!/bin/bash

## $Id$

#
# tomcat	Starts/stops the tomcat service
#
# chkconfig: 35 80 20
# description: Tomcat application server

### BEGIN INIT INFO
# Provides: tomcat
# Required-Start: $local_fs $network $syslog
# Required-Stop: $local_fs $syslog
# Should-Start: $syslog
# Should-Stop: $network $syslog
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Tomcat application server
# Description:       Tomcat application server
### END INIT INFO

/bin/su -s /bin/bash tomcat -- /opt/tomcat/bin/tomcat "$@"
