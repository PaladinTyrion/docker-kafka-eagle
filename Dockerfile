FROM openjdk:8-jdk-alpine
MAINTAINER paladintyrion <paladintyrion@gmail>

ENV KE_VERSION 1.2.0
ENV KE_HOME /opt/kafka-eagle
ENV KE_CONF $KE_HOME/conf
ENV KE_LOG /app/ke/log
ENV PATH $KE_HOME/bin:$PATH
ENV URL "https://github.com/PaladinTyrion/docker-kafka-eagle/releases/download/${KE_VERSION}"
ENV TARBALL "$URL/kafka-eagle-web-${KE_VERSION}-bin.tar.gz"

# install kafka-eagle
RUN apk update \
    && apk add --no-cache bash \
    && apk add --no-cache -t .build-deps wget openssl tar \
    && cd /tmp \
    && wget --no-check-certificate --progress=bar:force -O kafka-eagle.tar.gz "$TARBALL" \
    && mkdir -p "$KE_HOME" \
    && tar -zxf kafka-eagle.tar.gz --strip-components=1 -C "$KE_HOME" \
    && rm -f kafka-eagle.tar.gz \
    && apk del --purge .build-deps \
    && rm -fr /tmp/*

# install mysql & update mysql config
ENV MYSQL_LOG /app/mysql/log
COPY my.cnf /etc/my.cnf
RUN apk update \
    && mkdir -p /run/mysqld \
    && apk add --no-cache mysql mysql-client \
    && rm -rf /var/cache/apk/* \
    && rm -rf /var/lib/mysql/ib* \
    && mysql_install_db --user=root > /dev/null

# update kafka-eagle config & log4j
ENV KE_PORT 8999

RUN chmod +x $KE_HOME/bin/ke.sh
RUN mkdir -p ${MYSQL_LOG} \
    && mkdir -p ${KE_LOG}

VOLUME ["/var/lib/mysql", "/app/mysql/log", "/app/ke/log", "/opt/kafka-eagle/kms/logs"]
EXPOSE 8999 3306

# start mysql & ke.sh
WORKDIR /app/mysql

COPY startup.sh ./startup.sh
RUN chmod +x ./startup.sh

ENTRYPOINT ["startup.sh"]

CMD ["ke.sh", "start"]
