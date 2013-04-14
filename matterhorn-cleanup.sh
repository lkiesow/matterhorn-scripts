#!/bin/sh
echo This script will delete all matterhorn data
echo -n 'Are you shure you want to continue? : '
read CONFIRM
if [ "${CONFIRM%es}" = 'y' ]
then
	service matterhorn status && WAS_STARTED=true && service matterhorn stop

	echo -n 'Cleaning work directory...     '
	rm -rf /var/matterhorn/work/*
	echo done
	echo -n 'Cleaning storage directory...  '
	rm -rf /var/matterhorn/storage/*
	echo done
	echo -n 'Cleaning inbox directory...    '
	rm -rf /var/matterhorn/inbox/*
	echo done
	echo -n 'Cleaning log directory...      '
	rm -rf /var/log/matterhorn/*
	echo done

	[ $WAS_STARTED ] && service matterhorn start
else
	echo Aborting...
fi
