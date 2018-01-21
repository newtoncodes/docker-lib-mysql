FROM newtoncodes/ubuntu:16.04

RUN groupadd -r mysql && useradd -r -g mysql mysql

RUN apt-get update
RUN DEBIAN_FRONTEND="noninteractive" apt-get install -y mysql-server mysql-client pwgen
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN rm -rf /var/lib/mysql && mkdir -p /var/lib/mysql /var/run/mysqld
RUN mkdir -p /var/lib/mysql
RUN chown -R mysql:mysql /var/lib/mysql /var/log/mysql /var/run/mysqld && chmod 777 /var/run/mysqld

COPY mysqld.cnf /etc/mysql/mysql.conf.d/mysqld.cnf

COPY entrypoint.sh /usr/bin/entrypoint
RUN chmod +x /usr/bin/entrypoint

ENTRYPOINT ["/usr/bin/entrypoint"]
CMD ["mysqld"]

VOLUME ["/var/lib/mysql"]
EXPOSE 3306
