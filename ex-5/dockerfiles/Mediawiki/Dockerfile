FROM ubuntu:14.04
RUN apt-get update; apt-get install -y apache2 php5 php5-mysql wget

RUN mkdir /opt/init
RUN echo '#!/bin/bash \nset -x \n/usr/sbin/apache2ctl -DFOREGROUND' > /opt/init/entrypoint
RUN chmod +x /opt/init/entrypoint

WORKDIR /var/www/html
RUN wget -O mediawiki.tar.gz https://releases.wikimedia.org/mediawiki/1.28/mediawiki-1.28.2.tar.gz
RUN mkdir wiki
RUN tar xfvz mediawiki.tar.gz --strip 1 -C wiki
ADD LocalSettings.php /var/www/html/wiki/LocalSettings.php

ENTRYPOINT "/opt/init/entrypoint"