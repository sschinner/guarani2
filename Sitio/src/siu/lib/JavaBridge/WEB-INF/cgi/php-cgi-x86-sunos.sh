#!/bin/sh

# php wrapper

chmod +x ./php-cgi-x86-sunos
exec ./php-cgi-x86-sunos -c php-cgi-x86-sunos.ini "$@"
