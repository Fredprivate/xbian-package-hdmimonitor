#!/bin/bash

# initialize variable
start_xbmc=false
settings_file=/usr/local/etc/hdmimonitor/settings.conf

# check for configuration file
if [ -f "$settings_file" ]; then
	source $settings_file

	if [[ -z "$logfile" ]]; then
		logfile=/usr/local/etc/hdmimonitor/hdmimonitor.log
		echo "logfile=/usr/local/etc/hdmimonitor/hdmimonitor.log" >> $settings_file
	fi

	if [[ -z "$triggerline" ]]; then
                echo "$(date +"[%m-%d-%y %T]:") No triggerline set in configuration file, aborting" > $logfile
                exit 1
        fi

        if [[ -z "$XBMC_nice" ]]; then
                XBMC_nice=-3
                echo "XBMC_nice=-3" >> $settings_file
        fi


        if [[ -z "$enable_logging" ]]; then
                enable_logging=false
		echo "enable_logging=false" >> $settings_file
        fi

else
	if [ -d "/usr/local/etc/hdmimonitor" ]; then
		touch $settings_file
		echo "logfile=/usr/local/etc/hdmimonitor/hdmimonitor.log" >> $settings_file
		echo "" >> $settings_file
		echo "#triggerline=\"Please set triggerline and uncomment\"" >> $settings_file
		echo "XBMC_nice=-3" >> $settings_file
		echo "" >> $settings_file
		echo "enable_logging=false" >> $settings_file
		echo "$(date +"[%m-%d-%y %T]:") No configuration file found, created one, please modify." > /usr/local/etc/hdmimonitor/hdmimonitor.log
		exit 1
	else
		exit 1
	fi
fi

# remove old log file
if [ -f $logfile ]; then
	rm $logfile
fi

# create new log file

if $enable_logging; then
	touch $logfile
	echo "$(date +"[%m-%d-%y %T]:") Start logging" >> $logfile
fi

# check xbmc status

if [ $(sudo xbian-config services status xbmc | grep "xbmc 2" | wc -l) -eq 0 ]; then
        echo "$(date +"[%m-%d-%y %T]:") XBMC is either running or autostart is enabled, hdmimonitor does not want that, bye bye" >> $logfile
        exit 0
else
        echo "$(date +"[%m-%d-%y %T]:") Starting hdmi monitor" >> $logfile
fi

while true
do
# Monitoring starts
	while read line
	do

		if [[ $line == *$triggerline* ]]; then
			if $enable_logging; then
        			echo "$(date +"[%m-%d-%y %T]:") Recieved start signal HDMI" >> $logfile
			fi
			start_xbmc=true
			pkill -2 -f cec-client
		fi

		if $enable_logging; then
			echo "$(date +"[%m-%d-%y %T]: CEC-CLIENT OUTPUT:") $line" >> $logfile
		fi


	done < <(cec-client -t p -p 1 -m RPI)

# Monitoring ends (on trigger or cec-client fail)

	if $start_xbmc; then

                if $enable_logging; then
                        echo "$(date +"[%m-%d-%y %T]:") Starting XBMC" >> $logfile
                fi

    		sudo /usr/local/share/hdmimonitor/startxbmc.sh
: '
commented this bs------------------------------------------------------------------------------------------------------
		#check if xbmc has finished and is not rebooting
	       while true
        	do

        		if $enable_logging; then
        			echo "$(date +"[%m-%d-%y %T]:") XBMC has finished, waiting 20 seconds for it to come back to check if really finished" >> $logfile
        		fi

        	sleep 20

        		if [ ! $(ps -A | grep xbmc.bin | wc -l) -eq 0 ]; then
                		if $enable_logging; then
                        		echo "$(date +"[%m-%d-%y %T]:") XBMC has finished, but came back, checking again in 20 seconds" >> $logfile
                		fi

                		true
        		else
                		echo "$(date +"[%m-%d-%y %T]:") XBMC has finished, did not come back, assuming proper shutdown" >> $logfile
                		break
        		fi

        	done
-----------------------------------------------------------------------------------------------------------
'
                if $enable_logging; then
                        echo "$(date +"[%m-%d-%y %T]:") XBMC finished, continueing monitoring" >> $logfile
                fi

	else

                if $enable_logging; then
                        echo "$(date +"[%m-%d-%y %T]:") Error, probably failed cec-client, restarting monitor" >> $logfile
                fi

	fi

	start_xbmc=false
	sleep 0.5

done

exit 0
