#!/usr/bin/env bash

CPU_COUNT=`grep processor /proc/cpuinfo | wc -l`;
RAM_COUNT=$(($(printf "%.0f" `awk 'match($0,/MemTotal:/) {print $2}' /proc/meminfo`) / 1024))
HOST_IP=`/sbin/ip route|awk '/default/ { print $3 }'`;

sed -i "s/innodb_thread_concurrency.*/innodb_thread_concurrency       = $(($CPU_COUNT*2))/" /etc/mysql/mysql.conf.d/mysqld.cnf
sed -i "s/innodb_buffer_pool_size.*/innodb_buffer_pool_size         = $(printf "%.0f" $((($RAM_COUNT-512)*8/10)))M/" /etc/mysql/mysql.conf.d/mysqld.cnf


if [ ! -f /var/lib/mysql/ibdata1 ]; then
    echo "Initializing..."
    mkdir -p /var/lib/mysql
	chown -R mysql:mysql /var/lib/mysql
    mysqld --initialize-insecure
    echo "Database initialized."

    mysqld --skip-networking --socket=/var/run/mysqld/mysqld.sock &
    pid="$!"

    mysql=( mysql --protocol=socket -uroot -hlocalhost --socket=/var/run/mysqld/mysqld.sock )

    for i in {30..0}; do
        if echo 'SELECT 1' | "${mysql[@]}" &> /dev/null; then
            break
        fi
        echo 'MySQL init process in progress...'
        sleep 1
    done

    if [ "$i" = 0 ]; then
        echo >&2 'MySQL init process failed.'
        exit 1
    fi

    echo "Setting up users..."

    # sed is for https://bugs.mysql.com/bug.php?id=20545
    mysql_tzinfo_to_sql /usr/share/zoneinfo | sed 's/Local time zone must be set--see zic manual page/FCTY/' | "${mysql[@]}" mysql

    if [ "$ROOT_PASSWORD" = "" ]; then
        ROOT_PASSWORD="$(pwgen -1 32)"
        echo "GENERATED ROOT PASSWORD: $ROOT_PASSWORD"
    fi

    echo "
        SET @@SESSION.SQL_LOG_BIN=0;

        DELETE FROM mysql.user WHERE user NOT IN ('mysql.session', 'mysql.sys', 'root') OR host NOT IN ('localhost');

        SET PASSWORD FOR 'root'@'localhost'=PASSWORD('${ROOT_PASSWORD}');
        GRANT ALL ON *.* TO 'root'@'localhost' WITH GRANT OPTION;

        DROP DATABASE IF EXISTS test;
        FLUSH PRIVILEGES;
    " | "${mysql[@]}"

    if [ ! -z "$ROOT_PASSWORD" ]; then
        mysql+=( -p"${ROOT_PASSWORD}" )
    fi

    if ! kill -s TERM "$pid" || ! wait "$pid"; then
        echo >&2 'MySQL init process failed.'
        exit 1
    fi

    echo
    echo "MySQL init process done. Ready for start up."
fi

exec "$@"