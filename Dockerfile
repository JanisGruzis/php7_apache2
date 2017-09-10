FROM ubuntu:14.04

MAINTAINER Jānis Gruzis

# Update
RUN locale-gen en_US.UTF-8
RUN export LANG=en_US.UTF-8
RUN apt-key update
RUN apt-get update
RUN apt-get -y upgrade

# Add repositories
RUN apt-get install -y software-properties-common curl
RUN add-apt-repository ppa:ecometrica/servers
RUN LC_ALL=C.UTF-8 add-apt-repository ppa:ondrej/php
RUN apt-key update
RUN apt-get update

# Node
RUN apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_6.x | bash
RUN apt-get install -y build-essential nodejs
RUN npm install -g bower

# Install apps
RUN apt-get install -y wget xvfb libxss1 libgconf-2-4 libnss3-dev
RUN apt-get install -y apache2 jq acl fpc git unzip rsyslog wkhtmltopdf
RUN apt-get install -y php7.0 php7.0-xml php7.0-curl php7.0-mcrypt php7.0-gd php7.0-mysql php7.0-dev

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

EXPOSE 80
WORKDIR /var/www/html
CMD /usr/sbin/apache2ctl -D FOREGROUND
