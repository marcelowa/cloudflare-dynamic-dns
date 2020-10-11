#!/usr/bin/env sh

echo "Fetching Current IP"
CURRENT_IP=$(curl -s http://ipv4.icanhazip.com)

echo "Fetching Zone: $ZONE ID"
ZONE_ID=$(curl -s "https://api.cloudflare.com/client/v4/zones?name=$ZONE" -H "X-Auth-Email: $EMAIL" -H "X-Auth-Key: $API_KEY" -H "Content-Type: application/json" | jq -j ".result[0].id")

echo "Fetching Record: $HOST  Information"
GET_RECORD_RESPONSE=$(curl -s "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$HOST" -H "X-Auth-Email: $EMAIL" -H "X-Auth-Key: $API_KEY" -H "Content-Type: application/json")
RECORD_ID=$(echo $GET_RECORD_RESPONSE | jq -j ".result[0].id")
RECORD_TYPE=$(echo $GET_RECORD_RESPONSE | jq -j ".result[0].type")
RECORD_TTL=$(echo $GET_RECORD_RESPONSE | jq -j ".result[0].ttl")
RECORD_PROXIED=$(echo $GET_RECORD_RESPONSE | jq -j ".result[0].proxied")
RECORD_IP=$(echo $GET_RECORD_RESPONSE | jq -j ".result[0].content")

echo "Checking if record IP: $RECORD_IP matches the current IP: $CURRENT_IP"
if [ "$CURRENT_IP" == "$RECORD_IP" ]; then
    echo "Current IP matches the record IP, no need to update."
else
  echo "Record IP does not match the current IP, attempting to update..."
  
  UPDATE_PAYLOAD=$( jq -n \
    --arg zoneId "$ZONE_ID" \
    --arg recordType "$RECORD_TYPE" \
    --arg recordName "$HOST" \
    --arg recordTtl "$RECORD_TTL" \
    --arg recordProxied "$RECORD_PROXIED" \
    --arg currentIp "$CURRENT_IP" \
  '{id: $zoneId, type: $recordType, name: $recordName, ttl: $recordTtl, proxied: $recordProxied, content: $currentIp}' )

  UPDATE_RECORD_RESPONSE=$(curl -s -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" -H "X-Auth-Email: $EMAIL" -H "X-Auth-Key: $API_KEY" -H "Content-Type: application/json" --data "$(echo $UPDATE_PAYLOAD)")
  IS_SUCCESS=$(echo $UPDATE_RECORD_RESPONSE | jq -j ".success")

  if [ "$IS_SUCCESS" == true ]; then
    echo "Updated."
  else
    echo "Update failed."
    echo "Request:"
    echo "---"
    echo $UPDATE_PAYLOAD | jq .
    echo "Response:"
    echo "---"
    echo $UPDATE_RECORD_RESPONSE | jq .
  fi
fi
