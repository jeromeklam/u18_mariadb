# Version 1.0.3

FROM jeromeklam/u18
MAINTAINER Jérôme KLAM, "jeromeklam@free.fr"

ENV DEBIAN_FRONTEND noninteractive

## Install MariaDB.
ENV INITRD No
RUN apt-get update
RUN apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xF1656F24C74CD1D8
RUN add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://ftp.igh.cnrs.fr/pub/mariadb/repo/10.3/ubuntu/ bionic main'

# Supervisor
RUN apt-get update
COPY ./docker/supervisord.conf /etc/supervisor/conf.d/mysqld.conf

RUN apt-get update && \
    apt-get install -y mariadb-server && \
    sed -i 's/^\(bind-address\s.*\)/# \1/' /etc/mysql/my.cnf && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    update-rc.d -f mysql disable

ADD docker /scripts

RUN mkdir -p /db
# Expose our data, log, and configuration directories.
VOLUME ["/var/log/mysql", "/etc/mysql"]

EXPOSE 3306

# Use baseimage-docker's init system.
RUN chmod +x /scripts/start.sh
RUN /scripts/start.sh

## On démarre mysql, ...
CMD ["mysqld"]