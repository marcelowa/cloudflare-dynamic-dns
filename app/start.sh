#!/usr/bin/env sh
set -e

# Usage:
# Declare the following env variables:
# API_KEY your cloudflare public api key
# EMAIL eg. foobar@example.com
# ZONE the zone name, eg. example.com
# HOST the record name, eg. sub.example.com

if [ -z "$EMAIL" ]; then
    echo "EMAIL env variable is missing"
    exit 1
fi

if [ -z "$API_KEY" ]; then
    echo "API_KEY env variable is missing"
    exit 1
fi

if [ -z "$ZONE" ]; then
    echo "ZONE env variable is missing"
    exit 1
fi

if [ -z "$HOST" ]; then
    echo "HOST env variable is missing"
    exit 1
fi

crontab -l > current_crontab
echo "*/5 * * * * EMAIL=$EMAIL API_KEY=$API_KEY ZONE=$ZONE HOST=$HOST /app/cloudflare-dynamic-dns.sh" >> current_crontab 
crontab current_crontab

crond -f -L /dev/stdout
