FROM ubuntu:16.04

MAINTAINER Jānis Gruzis

# Update
RUN locale-gen en_US.UTF-8
RUN export LANG=en_US.UTF-8
RUN apt-key update
RUN apt-get update
RUN apt-get -y upgrade

# Node
RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -
RUN apt-get install -y build-essential nodejs
RUN npm install -g bower

# Install apps
RUN apt-get install -y wget xvfb libxss1 libgconf-2-4 libnss3-dev
RUN apt-get install -y apache2 jq acl fpc git unzip rsyslog wkhtmltopdf
RUN apt-get install -y php php-xml php-curl php-mcrypt php-gd php-mysql php-dev
RUN rsyslogd
RUN cron

WORKDIR /tmp

# Composer
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

# Janson
WORKDIR /tmp
RUN wget https://github.com/akheron/jansson/archive/v2.7.zip -O jansson.zip
RUN unzip jansson.zip

WORKDIR /tmp/jansson-2.7
RUN autoreconf -f -i
RUN ./configure --prefix=/usr --libdir=/usr/lib
RUN make
RUN make check
RUN make install

#LibSandbox
WORKDIR /tmp
RUN wget https://github.com/openjudge/sandbox/archive/V_0_3_x.zip -O sandbox.zip
RUN unzip sandbox.zip

WORKDIR /tmp/sandbox-V_0_3_x/libsandbox
RUN ./configure --prefix=/usr --libdir=/usr/lib
RUN make install

# Markdown
WORKDIR /tmp
RUN git clone https://github.com/chobie/php-sundown.git php-sundown --recursive

WORKDIR /tmp/php-sundown
RUN phpize
RUN ./configure --prefix=/usr --libdir=/usr/lib
RUN make
RUN make install
RUN bash -c "echo 'extension=sundown.so' >> /etc/php/5.6/apache2/php.ini"
RUN bash -c "echo 'extension=sundown.so' >> /etc/php/5.6/cli/php.ini"

# PHPRedis
WORKDIR /tmp
RUN wget https://github.com/phpredis/phpredis/archive/master.zip
RUN unzip master.zip

WORKDIR /tmp/phpredis-master
RUN phpize
RUN ./configure
RUN make
RUN make install
RUN bash -c "echo 'extension=redis.so' >> /etc/php/5.6/apache2/php.ini"
RUN bash -c "echo 'extension=redis.so' >> /etc/php/5.6/cli/php.ini"

EXPOSE 80
WORKDIR /var/www/html
CMD /usr/sbin/apache2ctl -D FOREGROUND
