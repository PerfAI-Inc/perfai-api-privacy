#!/bin/bash

TEMP=$(getopt -n "$0" -a -l "username:,password:" -- -- "$@")

[ $? -eq 0 ] || exit

eval set -- "$TEMP"

while [ $# -gt 0 ]
do
    case "$1" in
        --username) PERFAI_USERNAME="$2"; shift;;
        --password) PERFAI_PASSWORD="$2"; shift;;
        --) shift ;;
    esac
    shift;
done

echo " "

if [ "$PERFAI_HOSTNAME" = "" ];
then
PERFAI_HOSTNAME="https://app.apiprivacy.com"
fi

### Step 1:Authenticate User Get Token
TOKEN_RESPONSE=$(curl -s --location --request POST "https://api.perfai.ai/api/v1/auth/token" \
--header "Content-Type: application/json" \
--data-raw "{
    \"username\": \"${PERFAI_USERNAME}\",
    \"password\": \"${PERFAI_PASSWORD}\"
}")

ACCESS_TOKEN=$(echo $TOKEN_RESPONSE | jq -r '.id_token')

if [ -z "$ACCESS_TOKEN" ]; then
    echo "Failed to retrieve access token."
    echo "Response was: $TOKEN_RESPONSE"
    exit 1
fi

echo "Access Token is: $ACCESS_TOKEN"
echo " "

### Step 2: Generating Catalog Ids ###
CATALOG_RESPONSE=$(curl -s --location --request GET "https://api.perfai.ai/api/v1/sensitive-data-service/apps/all?page=1&pageSize=10" \
--header "Authorization: Bearer $ACCESS_TOKEN")

CATALOG_ID=$(echo $CATALOG_RESPONSE | jq -r '.data[].catalog_id')

if [ -z "$CATALOG_ID" ]; then
    echo "Failed to retrieve catalog ID."
    echo "Response was: $CATALOG_RESPONSE"
fi

echo "Catalog ID is: $CATALOG_ID"
echo " "
