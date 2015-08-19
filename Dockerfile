FROM debian:jessie

MAINTAINER Gary Ritchie <gary@garyritchie.com>

RUN echo "deb http://httpredir.debian.org/debian jessie main" > /etc/apt/sources.list
RUN echo "deb http://httpredir.debian.org/debian jessie-updates main" >> /etc/apt/sources.list
RUN echo "deb http://security.debian.org jessie/updates main" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y \
	lighttpd \
	php5-cgi \
	git \
	&& apt-get clean

RUN lighttpd-enable-mod fastcgi-php
RUN /etc/init.d/lighttpd restart

## Add the following to the end of /etc/sudoers:

# RUN  cat /etc/sudoers <<EOF
# www-data ALL=(ALL) NOPASSWD:/sbin/ifdown wlan0,/sbin/ifup wlan0,/bin/cat /etc/wpa_supplicant/wpa_supplicant.conf,/bin/cp /tmp/wifidata 
# /etc/wpa_supplicant/wpa_supplicant.conf,/sbin/wpa_cli scan_results, /sbin/wpa_cli scan,/bin/cp /tmp/hostapddata /etc/hostapd/hostapd.conf,
# /etc/init.d/hostapd start,/etc/init.d/hostapd stop,/etc/init.d/dnsmasq start,/etc/init.d/dnsmasq stop,/bin/cp /tmp/dhcpddata /etc/dnsmasq.conf
# EOF

RUN git clone https://github.com/billz/raspap-webgui /var/www/html/ap
RUN chown -R www-data:www-data /var/www/html

EXPOSE 80

ENTRYPOINT ["lighttpd", "-D", "-f", "/etc/lighttpd/lighttpd.conf"]