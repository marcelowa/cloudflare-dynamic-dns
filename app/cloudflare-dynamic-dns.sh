#!/usr/bin/env sh

echo "$(date) attempting IP update for $CLOUDFLARE_ZONE $CLOUDFLARE_HOST"
echo "$(date) Fetching Current IP"
CURRENT_IP=$(curl -s http://ipv4.icanhazip.com)

echo "$(date) Current IP $CURRENT_IP"

echo "$(date) Fetching Zone: $CLOUDFLARE_ZONE ID"
ZONE_ID=$(curl -s "https://api.cloudflare.com/client/v4/zones?name=$CLOUDFLARE_ZONE" -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" | jq -j ".result[0].id")

echo "$(date) Fetching Record: $CLOUDFLARE_HOST Information"
GET_RECORD_RESPONSE=$(curl -s "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$CLOUDFLARE_HOST" -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN")

RECORD_ID=$(echo $GET_RECORD_RESPONSE | jq -j ".result[0].id")
RECORD_TYPE=$(echo $GET_RECORD_RESPONSE | jq -j ".result[0].type")
RECORD_TTL=$(echo $GET_RECORD_RESPONSE | jq -j ".result[0].ttl")
RECORD_PROXIED=$(echo $GET_RECORD_RESPONSE | jq -j ".result[0].proxied")
RECORD_IP=$(echo $GET_RECORD_RESPONSE | jq -j ".result[0].content")

echo "$(date) Checking if record IP: $RECORD_IP matches the current IP: $CURRENT_IP"
if [ "$CURRENT_IP" == "$RECORD_IP" ]; then
  echo "$(date) Current IP matches the record IP, no need to update."
else
  echo "$(date) Record IP does not match the current IP, attempting to update..."
  
  UPDATE_PAYLOAD=$( jq -n \
    --arg recordName $CLOUDFLARE_HOST \
    --argjson recordTtl $RECORD_TTL \
    --arg recordType $RECORD_TYPE \
    --arg currentIp $CURRENT_IP \
    --argjson recordProxied $RECORD_PROXIED \
  '{name: $recordName, ttl: $recordTtl, type: $recordType, comment: "updated by cloudflare-dynamic-dns", content: $currentIp, proxied: $recordProxied}' )

  UPDATE_RECORD_RESPONSE=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" --data "$(echo $UPDATE_PAYLOAD)")

  IS_SUCCESS=$(echo $UPDATE_RECORD_RESPONSE | jq -j ".success")
        
  if [ "$IS_SUCCESS" == true ]; then
    echo "$(date) Updated."
  else
    echo "$(date) Update failed."
    echo "$(date) Request:"
    echo "---"
    echo $UPDATE_PAYLOAD | jq .
    echo "$(date) Response:"
    echo "---"
    echo $UPDATE_RECORD_RESPONSE | jq .
  fi
fi
