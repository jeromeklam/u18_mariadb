#!/bin/bash
# Starts up MariaDB within the container.

# Stop on error
set -e

if [ -d /data ]; then
  if [ -f /data/firstrun.ok ]; then
    echo "normal run..."
    source /scripts/normal_run.sh
  else
    echo "first run..."
    source /scripts/first_run.sh
  fi
else
  if [ -f /var/lib/mysql/firstrun.ok ]; then
    echo "normal run..."
    source /scripts/normal_run.sh
  else
    echo "first run..."
    source /scripts/first_run.sh
  fi
fi

wait_for_mysql_and_run_post_start_action() {
  # Wait for mysql to finish starting up first.
  echo -n "."
  test=`/etc/init.d/mysql status | grep Uptime`
  while [ "$test" = "" ]; do
      sleep 1
      echo -n "."
  done
  echo "! done"
  echo "post_start_action..."
  post_start_action
  echo "post_start_action..."
}

echo "pre_start_action..."
pre_start_action
echo "pre_start_action ok"

wait_for_mysql_and_run_post_start_action

# Start MariaDB
echo "Starting MariaDB..."
/usr/bin/supervisord -n
