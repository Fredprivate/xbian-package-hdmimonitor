HDMI monitor for xbian
======================
This is not the official xbian package, but build for personal use.

This package automatically starts XBMC when the hdmi channel is accessed. 
It is configured for working with a Samsung tv, the settings can be changed in the settings file. 

To find the triggerline you need, start up 'cec-client -m' in a terminal which monitors all cec traffic. 


Limitations:
You have to disable XBMC autostart and can't use the init file for XBMC anymore (it is not disabled but can result in unwanted behaviour when HDMI monitor is running)
A modded init file for XBMC is included, xbmcmod. So 'sudo /etc/init.d/xbmc start' becomes 'sudo /etc/init.d/xbmcmod start' etc.

