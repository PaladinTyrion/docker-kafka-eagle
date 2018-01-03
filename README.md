docker run -d --net=host --privileged -p 3306:3306 -p 8999:8999 -v /data0/kafka-eagle/mysql/data:/var/lib/mysql -v /data0/kafka-eagle/mysql/log:/app/mysql/log -v /data0/kafka-eagle/ke/log:/app/ke/log -v /data0/kafka-eagle/tomcat/log:/opt/kafka-eagle/kms/logs -e KAFKA_CLUSTER=0.0.0.0:2181 --name=kafka-eagle registry.api.weibo.com/multi-media-structure/kafka-eagle-1.2.0