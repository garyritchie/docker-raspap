FROM debian:wheezy

MAINTAINER Gary Ritchie <gary@garyritchie.com>

# RUN apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 0x908332071dd2e32e
# RUN echo "deb http://deb.best-hosting.cz/debian/ wheezy main" > /etc/apt/sources.list.d/best-hosting.list

RUN wget https://archive.raspbian.org/raspbian.public.key -O - | sudo apt-key add - &&
	echo "deb http://archive.raspbian.org/raspbian wheezy main contrib non-free" > /etc/apt/sources.list.d/raspbian.list &&
	echo "deb-src http://archive.raspbian.org/raspbian wheezy main contrib non-free" >> /etc/apt/sources.list.d/raspbian.list

# RUN echo "deb http://httpredir.debian.org/debian wheezy main" > /etc/apt/sources.list
# RUN echo "deb http://httpredir.debian.org/debian wheezy-updates main" >> /etc/apt/sources.list
# RUN echo "deb http://security.debian.org wheezy/updates main" >> /etc/apt/sources.list

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -q -y install \
	nano \
	sudo \
	net-tools \
	wireless-tools \
	lighttpd \
	php5-cgi \
	git \
	&& apt-get clean

RUN lighty-enable-mod fastcgi-php
RUN /etc/init.d/lighttpd restart

# AP stuff
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -q -y install \
	wget \
	unzip \
	bridge-utils \
	hostapd \
	rfkill \
	hostap-utils \
	iw \
	dnsmasq \
	&& apt-get clean

RUN wget http://dl.dropbox.com/u/1663660/hostapd/hostapd.zip

RUN unzip hostapd.zip && \
	mv /usr/sbin/hostapd /usr/sbin/hostapd.original && \
	mv hostapd /usr/sbin/hostapd.edimax && \
	ln -sf /usr/sbin/hostapd.edimax /usr/sbin/hostapd && \
	chown root.root /usr/sbin/hostapd && \
	chmod 755 /usr/sbin/hostapd

## Add the following to the end of /etc/sudoers:

RUN echo 'www-data ALL=(ALL) NOPASSWD:/sbin/ifdown wlan0,/sbin/ifup wlan0,/bin/cat /etc/wpa_supplicant/wpa_supplicant.conf,/bin/cp /tmp/wifidata \
/etc/wpa_supplicant/wpa_supplicant.conf,/sbin/wpa_cli scan_results, /sbin/wpa_cli scan,/bin/cp /tmp/hostapddata /etc/hostapd/hostapd.conf, \
/etc/init.d/hostapd start,/etc/init.d/hostapd stop,/etc/init.d/dnsmasq start,/etc/init.d/dnsmasq stop,/bin/cp /tmp/dhcpddata /etc/dnsmasq.conf' > /etc/sudoers.d/www-data

RUN chmod 0440 /etc/sudoers.d/www-data
RUN git clone https://github.com/billz/raspap-webgui /var/www/ap
RUN chown -R www-data:www-data /var/www

EXPOSE 80

ENTRYPOINT ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]