#!/bin/bash

# This file is normally called by hdmimonitor.sh, so files and variables are not checked for existence. 

XBMC_nice=$1

if [ $(ps -A | grep xbmc.bin | wc -l) -eq 0 ]; then

#put everything before starting xbmc before this.

	DESC=XBMC
	NAME=xbmc.bin
	DAEMON=/usr/local/lib/xbmc/$NAME
	DAEMON_ARGS="--standalone"
	PIDFILE=/var/run/xbmc.pid
	PATH=/sbin:/usr/sbin:/bin:/usr/bin
	NICE=$XBMC_nice

	. /lib/init/vars.sh
	. /lib/lsb/init-functions

# Exit if the package is not installed
	[ -x $DAEMON ] || exit 0

	start-stop-daemon -c xbian -u xbian --start --quiet --pidfile $PIDFILE --exec $DAEMON --test || return 1;
	echo $(start-stop-daemon -c xbian -u xbian -m --start --nicelevel $NICE --pidfile $PIDFILE --exec $DAEMON -- $DAEMON_ARGS; RETURN=$?; case $RETURN in 64 ) splash --infinitebar --msgtxt="shutting down..."; sudo halt ;; 66 ) splash --infinitebar --msgtxt="rebooting..."; sudo reboot; ;; esac || return 2)


#every thing after xbmc has exited
	pkill splash

#start hdmimonitor (for when XBMC is started from init script)

	if [ -f "/etc/init.d/hdmimonitor" ]; then
		sudo /etc/init.d/hdmimonitor start >/dev/null &
	fi

#else

#	if $enable_logging; then
#		echo "$(date +"[%m-%d-%y %T]:") Want to start XBMC, but XBMC is already running" >> $logfile
#	fi

fi

exit 0
