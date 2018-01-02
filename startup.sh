#!/bin/bash

if [ "$MYSQL_ROOT_PASSWORD" = "" ]; then
  MYSQL_ROOT_PASSWORD="paladin"
fi

if [ "$KAFKA_CLUSTER" = "" ]; then
  KAFKA_CLUSTER="0.0.0.0:2181"
fi

tfile=`mktemp`
if [ ! -f "$tfile" ]; then
    return 1
fi

cat << EOF > $tfile
USE mysql;
FLUSH PRIVILEGES;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY "$MYSQL_ROOT_PASSWORD" WITH GRANT OPTION;
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
UPDATE user SET password=PASSWORD("") WHERE user='root' AND host='localhost';
EOF

mysqld --user=root --bootstrap --verbose=0 < $tfile
rm -f $tfile

nohup mysqld --user=root >$MYSQL_LOG/mysqld.log 2>&1 &

sed -i -e "s#^log4j.appender.SLOG.File=.*\$#log4j.appender.SLOG.File=/app/ke/log/log.log#" $KE_HOME/conf/log4j.properties
sed -i -e "s#^log4j.appender.SLOG.Threshold=.*\$#log4j.appender.SLOG.Threshold=INFO#" $KE_HOME/conf/log4j.properties
sed -i -e "s#^log4j.appender.SERROR.File=.*\$#log4j.appender.SERROR.File=/app/ke/log/error.log#" $KE_HOME/conf/log4j.properties

sed -i -e "s#^kafka.eagle.zk.cluster.alias=.*\$#kafka.eagle.zk.cluster.alias=kafkacluster#" $KE_HOME/conf/system-config.properties
sed -i -e "s#^cluster1.zk.list=.*\$#kafkacluster.zk.list=${KAFKA_CLUSTER}#" $KE_HOME/conf/system-config.properties
sed -i -e "/^cluster2.zk.list=.*$/d" $KE_HOME/conf/system-config.properties
sed -i -e "s#^kafka.eagle.webui.port=.*\$#kafka.eagle.webui.port=${KE_PORT}#" $KE_HOME/conf/system-config.properties
sed -i -e "s#^kafka.eagle.mail.enable=.*\$#kafka.eagle.mail.enable=false#" $KE_HOME/conf/system-config.properties
sed -i -e "s#^kafka.eagle.password=.*\$#kafka.eagle.password=${MYSQL_ROOT_PASSWORD}#" $KE_HOME/conf/system-config.properties

exec "$@"
