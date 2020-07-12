#!/bin/bash

set -e

sed -i "s|ZM_DB_HOST=.*|ZM_DB_HOST=${ZM_DB_HOST}|" /etc/zm/zm.conf
sed -i "s|ZM_DB_NAME=.*|ZM_DB_NAME=${ZM_DB_NAME}|" /etc/zm/zm.conf
sed -i "s|ZM_DB_USER=.*|ZM_DB_USER=${ZM_DB_USER}|" /etc/zm/zm.conf
sed -i "s|ZM_DB_PASS=.*|ZM_DB_PASS=${ZM_DB_PASS}|" /etc/zm/zm.conf
sed -i "s|ZM_DB_PORT=.*|ZM_DB_PORT=${ZM_DB_PORT}|" /etc/zm/zm.conf
grep -q ZM_DB_PORT /etc/zm/zm.conf || echo ZM_DB_PORT=$ZM_DB_PORT >>/etc/zm/zm.conf

# Returns true once mysql can connect.
mysql_ready() {
  mysqladmin ping --host=$ZM_DB_HOST --port=$ZM_DB_PORT --user=$ZM_DB_USER --password=$ZM_DB_PASS >/dev/null 2>&1
}

# waiting for mysql
while !(mysql_ready); do
  sleep 3
  echo "waiting for mysql ..."
done

# check if database is empty and fill it if necessary
EMPTYDATABASE=$(mysql -u$ZM_DB_USER -p$ZM_DB_PASS --host=$ZM_DB_HOST --port=$ZM_DB_PORT --batch --skip-column-names -e "use ${ZM_DB_NAME} ; show tables;" | wc -l)
# [ -f /var/cache/zoneminder/configured ]
if [[ $EMPTYDATABASE != 0 ]]; then
  echo 'database already configured.'
  zmupdate.pl -nointeractive
else
  # if ZM_DB_NAME different that zm
  cp /usr/share/zoneminder/db/zm_create.sql /usr/share/zoneminder/db/zm_create.sql.backup
  sed -i "s|-- Host: localhost Database: .*|-- Host: localhost Database: ${ZM_DB_NAME}|" /usr/share/zoneminder/db/zm_create.sql
  sed -i "s|-- Current Database: .*|-- Current Database: ${ZM_DB_NAME}|" /usr/share/zoneminder/db/zm_create.sql
  sed -i "s|CREATE DATABASE \/\*\!32312 IF NOT EXISTS\*\/ .*|CREATE DATABASE \/\*\!32312 IF NOT EXISTS\*\/ \`${ZM_DB_NAME}\` \;|" /usr/share/zoneminder/db/zm_create.sql
  sed -i "s|USE .*|USE ${ZM_DB_NAME} \;|" /usr/share/zoneminder/db/zm_create.sql

  # prep the database for zoneminder
  mysql -u $ZM_DB_USER -p$ZM_DB_PASS -h $ZM_DB_HOST -P$ZM_DB_PORT $ZM_DB_NAME </usr/share/zoneminder/db/zm_create.sql

fi

rm -rf /var/run/zm/*

# Launching apache2 in the background
source /etc/apache2/envvars
/usr/sbin/apache2 -k start

# Launching zoneminder
/usr/bin/zmpkg.pl start >>/var/log/zm/zm.log 2>&1

tail -f /var/log/zm/zm.log
