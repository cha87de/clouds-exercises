FROM ubuntu:16.04
RUN apt-get update; apt-get install -y apache2 php php-mysql php-mbstring php-xml libapache2-mod-php wget

RUN mkdir /opt/init
RUN echo '#!/bin/bash \nset -x \n/usr/sbin/apache2ctl -DFOREGROUND' > /opt/init/entrypoint
RUN chmod +x /opt/init/entrypoint

WORKDIR /var/www/html
RUN wget -O mediawiki.tar.gz https://releases.wikimedia.org/mediawiki/1.28/mediawiki-1.28.2.tar.gz
RUN mkdir wiki
RUN tar xfvz mediawiki.tar.gz --strip 1 -C wiki
ADD LocalSettings.php /var/www/html/wiki/LocalSettings.php

RUN sed -i "s/Require local/Require ip 172.0.0.0\/8/"  /etc/apache2/mods-available/status.conf

ENTRYPOINT "/opt/init/entrypoint"