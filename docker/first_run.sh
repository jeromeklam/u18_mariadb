USER=${USER:-super}
PASS=${PASS:-YggDrasil}

pre_start_action() {
  echo "MARIADB_USER=$USER"
  echo "MARIADB_PASS=$PASS"
  if [ "${LOCAL}" = "" ]; then
    echo "no mount, mysql stay in place..."
    touch /var/lib/mysql/firstrun.ok
  else
    # Echo out info to later obtain by running `docker logs container_name`
    echo "moving..."
    rm -f /run/mysqld/mysqld.sock
    mv /var/lib/mysql /data/mysql
    ln -sf /data/mysql /var/lib/mysql
    ls -l /data/mysql
    echo "moving done..."
    chown -R mysql.mysql /data/mysql
    chown mysql.mysql /var/lib/mysql
    touch /data/firstrun.ok
  fi
  if [ -f /data/my.cnf ]; then
    cp -f /data/my.cnf /etc/mysql/my.cnf
  fi
  /etc/init.d/mysql restart
}

post_start_action() {
  # The password for 'debian-sys-maint'@'localhost' is auto generated.
  # So, we need to set this for our database to be portable.
  DB_MAINT_PASS=$(cat /etc/mysql/debian.cnf | grep -m 1 "password\s*=\s*"| sed 's/^password\s*=\s*//')
  echo "$DB_MAINT_PASS..."
  mysql -u root -e \
      "GRANT ALL PRIVILEGES ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY '$DB_MAINT_PASS';"
  echo "creating users..."
  # Create the superuser, ...
  mysql -u root <<-EOF
      DELETE FROM mysql.user WHERE user = '$USER';
      DELETE FROM mysql.user WHERE user = 'super';
      FLUSH PRIVILEGES;
      CREATE USER '$USER' IDENTIFIED BY '$PASS';
      GRANT ALL PRIVILEGES ON *.* TO '$USER'@'localhost' IDENTIFIED BY '$PASS';
      GRANT ALL PRIVILEGES ON *.* TO '$USER'@'%' IDENTIFIED BY '$PASS';
EOF

  echo "verifying dumps..."
  if [ "$DUMP" != "" ]; then
    set -f                      # avoid globbing (expansion of *).
    echo "processing $DUMP..."
    array=(${DUMP//:/ })
    for i in "${!array[@]}"
    do
      crt=${array[i]}
      if [ -f $crt ]; then
        echo "importing $crt..."
        filename=$(basename "$crt")
        extension="${filename##*.}"
        filename="${filename%.*}"
        mysql -usuper -pYggDrasil -e "CREATE DATABASE \`$filename\`;"
        mysql -usuper -pYggDrasil "$filename" < "$crt"
        echo "done."
      else
        echo "$crt not found !"
      fi
    done
  else
    echo "nothing..."
  fi
  echo "ok..."
}
