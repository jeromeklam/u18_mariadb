pre_start_action() {
  # Cleanup previous sockets
  echo "cleanup"
  if [ -d /data ]; then
    if [ -L /var/lib/mysql ]; then
      echo "datadir ok..."
    else
      echo "moving..."
      rm -rf /var/lib/mysql
      ln -sf /data/mysql /var/lib/mysql
      touch /data/firstrun.ok
      echo "moving done..."
    fi;
  fi
  rm -f /run/mysqld/mysqld.sock
  /etc/init.d/mysql restart
}

post_start_action() {
  # nothing
  echo "."
}
