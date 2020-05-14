pre_start_action() {
  # Cleanup previous sockets
  echo "cleanup"
  if [ ! -L /db ]; then
    if [ -L /var/lib/mysql ]; then
      echo "datadir ok..."
    else
      echo "moving..."
      rm -rf /var/lib/mysql
      ln -sf /db/mysql /var/lib/mysql
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
