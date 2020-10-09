#!/usr/bin/env sh

echo "Fetching Current IP"
CURRENT_IP=$(curl -s http://ipv4.icanhazip.com)

echo "Fetching Zone: $ZONE ID"
ZONE_ID=$(curl -s "https://api.cloudflare.com/client/v4/zones?name=$ZONE" -H "X-Auth-Email: $EMAIL" -H "X-Auth-Key: $API_KEY" -H "Content-Type: application/json" | jq -j ".result[0].id")

echo "Fetching Record: $HOST  Information"
RECORD_ID_RESULT=$(curl -s  "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?name=$HOST" -H "X-Auth-Email: $EMAIL" -H "X-Auth-Key: $API_KEY" -H "Content-Type: application/json")
RECORD_ID=$(echo $RECORD_ID_RESULT | jq -j ".result[0].id")
RECORD_IP=$(echo $RECORD_ID_RESULT | jq -j ".result[0].content")
RECORD_TYPE=$(echo $RECORD_ID_RESULT | jq -j ".result[0].type")
RECORD_TTL=$(echo $RECORD_ID_RESULT | jq -j ".result[0].ttl")

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
    --arg currentIp "$CURRENT_IP" \
  '{id: $zoneId, type: $recordType, name: $recordName, ttl: $recordTtl, content: $currentIp}' )
  UPDATE_RESPONSE=$(curl -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" -H "X-Auth-Email: $EMAIL" -H "X-Auth-Key: $API_KEY" -H "Content-Type: application/json" --data "$(echo $UPDATE_PAYLOAD)")
  IS_SUCCESS=$(echo $UPDATE_RESPONSE | jq -j ".result.success")
  if [ "$IS_SUCCESS" == true ]; then
    echo "Updated."
  else
    echo "Update failed, see response:"
    echo UPDATE_RESPONSE | jq .
  fi
fi
