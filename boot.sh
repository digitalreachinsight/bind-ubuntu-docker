#!/bin/bash

shared_dir="/shared-mount"

service syslog-ng start &
status=$?
if [ $status -ne 0 ]; then
    echo "Failed to start syslog-ng: $status"
    exit $status
fi

if [ -d "$shared_dir/domains" ]
then
   echo "File Exists $shared_dir/domains"
else
   mkdir $shared_dir/domains
fi

mv /etc/bind/named.conf /etc/bind/named.conf-container
ln -s $shared_dir/named.conf /etc/bind/named.conf
ln -s $shared_dir/domains /etc/bind/domains
# Start the first process
env > /etc/.cronenv
rm /etc/cron.d/dockercron
ln -s /shared-mount/dockercron /etc/cron.d/dockercron

service cron start &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start cron: $status"
  exit $status
fi

echo mail-relay-container > /etc/mailname
#postmap /etc/postfix/sasl/sasl_passwd

service postfix start &
status=$?
if [ $status -ne 0 ]; then
	  echo "Failed to start postfix: $status"
    exit $status
fi

# Start the second process
service named start &
status=$?
if [ $status -ne 0 ]; then
  echo "Failed to start bind9: $status"
  exit $status
fi
bash
