#!/bin/bash

if [ "$KAFKA_CLUSTER" = "" ]; then
  KAFKA_CLUSTER="0.0.0.0:2181"
fi

mysql_install_db --user=root > /dev/null

nohup mysqld --user=root >$MYSQL_LOG/mysqld.log 2>&1 &

sed -i -e "s#^log4j.appender.SLOG.File=.*\$#log4j.appender.SLOG.File=/app/ke/log/log.log#" $KE_HOME/conf/log4j.properties
sed -i -e "s#^log4j.appender.SLOG.Threshold=.*\$#log4j.appender.SLOG.Threshold=INFO#" $KE_HOME/conf/log4j.properties
sed -i -e "s#^log4j.appender.SERROR.File=.*\$#log4j.appender.SERROR.File=/app/ke/log/error.log#" $KE_HOME/conf/log4j.properties

sed -i -e "s#^kafka.eagle.zk.cluster.alias=.*\$#kafka.eagle.zk.cluster.alias=kafkacluster#" $KE_HOME/conf/system-config.properties
sed -i -e "s#^cluster1.zk.list=.*\$#kafkacluster.zk.list=${KAFKA_CLUSTER}#" $KE_HOME/conf/system-config.properties
sed -i -e "/^cluster2.zk.list=.*$/d" $KE_HOME/conf/system-config.properties
sed -i -e "s#^kafka.eagle.webui.port=.*\$#kafka.eagle.webui.port=${KE_PORT}#" $KE_HOME/conf/system-config.properties
sed -i -e "s#^kafka.eagle.mail.enable=.*\$#kafka.eagle.mail.enable=false#" $KE_HOME/conf/system-config.properties
sed -i -e "s#^kafka.eagle.password=.*\$#kafka.eagle.password=123456#" $KE_HOME/conf/system-config.properties

ke.sh start

tail -f /app/ke/log/error.log

exec "$@"
