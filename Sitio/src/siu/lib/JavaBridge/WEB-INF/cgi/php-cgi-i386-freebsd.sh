#!/bin/sh

# php wrapper

chmod +x ./php-cgi-i386-freebsd
exec ./php-cgi-i386-freebsd -c php-cgi-i386-freebsd.ini "$@"
