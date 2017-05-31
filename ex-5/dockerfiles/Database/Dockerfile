FROM  mariadb:5.5

ENV MYSQL_ALLOW_EMPTY_PASSWORD yes
ENV MYSQL_ROOT_PASSWORD=""
ENV MYSQL_DATABASE wikidb
ENV MYSQL_USER wikiuser
ENV MYSQL_PASSWORD geheim

ADD dump.sql /docker-entrypoint-initdb.d/dump.sql