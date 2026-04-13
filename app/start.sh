#!/usr/bin/env sh
set -e

# Usage:
# Declare the following env variables:
# CLOUDFLARE_API_TOKEN your cloudflare public api key
# CLOUDFLARE_ZONE the zone name, eg. example.com
# CLOUDFLARE_HOST the record name, eg. sub.example.com

echo "Welcome to cloudflare-dynamic-dns";

if [ -z "$CLOUDFLARE_API_TOKEN" ]; then
    echo "CLOUDFLARE_API_TOKEN env variable is missing"
    exit 1
fi

if [ -z "$CLOUDFLARE_ZONE" ]; then
    echo "CLOUDFLARE_ZONE env variable is missing"
    exit 1
fi

if [ -z "$CLOUDFLARE_HOST" ]; then
    echo "CLOUDFLARE_HOST env variable is missing"
    exit 1
fi

crontab -l > current_crontab
echo "*/5 * * * * API_TOKEN=$CLOUDFLARE_API_TOKEN ZONE=$CLOUDFLARE_ZONE HOST=$CLOUDFLARE_HOST /app/cloudflare-dynamic-dns.sh" >> current_crontab 
crontab current_crontab
(sleep 1 && /app/cloudflare-dynamic-dns.sh) &
crond -f -L /dev/stdout
