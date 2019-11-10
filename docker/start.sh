#!/bin/bash
# Starts up MariaDB within the container.

# Stop on error
set -e

if [ -d /data ]; then
  if [[ -e /data/firstrun.ok ]]; then
    echo "normal run..."
    source /scripts/normal_run.sh
  else
    echo "first run..."
    source /scripts/first_run.sh
  fi
else
  if [[ -e /var/lib/mysql/firstrun.ok ]]; then
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
  while [ ! -e /run/mysqld/mysqld.sock ]; do
      sleep 1
      echo -n "."
  done
  echo "!"
  post_start_action
}

pre_start_action

wait_for_mysql_and_run_post_start_action &

# Start MariaDB
echo "Starting MariaDB..."
exec /usr/bin/mysqld_safe
