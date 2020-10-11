#!/bin/bash

export _timestamp=$(date -u '+%Y-%d-%m_%H%M')
export _location=cloudflare_zones_${_timestamp}
mkdir -p ${_location}

curl --silent \
  --header "X-Auth-Email: $CLOUDFLARE_EMAIL" --header "X-Auth-Key: $CLOUDFLARE_API_KEY" --header "Content-Type: application/json" \
  --request GET https://api.cloudflare.com/client/v4/zones | jq > ${_location}/zones.json


for _zone in $(jq --raw-output '.result[] | .id' ${_location}/zones.json); do
  _name=$(jq --raw-output --arg zone_id "${_zone}" '.result[] | select(.id==$zone_id) | .name' ${_location}/zones.json)

  curl --silent \
    --header "X-Auth-Email: $CLOUDFLARE_EMAIL" --header "X-Auth-Key: $CLOUDFLARE_API_KEY" --header "Content-Type: application/json" \
    --request GET https://api.cloudflare.com/client/v4/zones/${_zone}/dns_records | jq > ${_location}/zone_${_name}_records.json
done
