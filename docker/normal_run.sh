pre_start_action() {
  # Cleanup previous sockets
  if [ -d /data ]; then
    if [ -L /var/lib/mysql ]; then
      echo "datadir ok..."
    else
      echo "moving..."
      rm -rf /var/lib/mysql
      ln -sf /data/mysql /var/lib/mysql
      echo "moving done..."
    fi;
  fi
  rm -f /run/mysqld/mysqld.sock
}

post_start_action() {
  # nothing
  echo "."
}
