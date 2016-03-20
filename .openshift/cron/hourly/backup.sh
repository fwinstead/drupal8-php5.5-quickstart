#!/bin/bash

# backup at 4am

hour=$(date +%H)
if [[ $hour =~ 4$ ]]
then
	NOW=$(date "+%Y_%m_%d_%H_%M")
	echo "${NOW} Backup to Dropbox using: ${DROPBOX_TOKEN}" >> /tmp/backup.log
fi


