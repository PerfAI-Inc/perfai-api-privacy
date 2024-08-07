#!/bin/bash

TEMP=$(getopt -n "$0" -a -l "hostname:,username:,password:" -- -- "$@")

[ $? -eq 0 ] || exit

eval set -- "$TEMP"

while [ $# -gt 0 ]
do
    case "$1" in
        --hostname) PERFAI_HOSTNAME="$2"; shift;;
        --username) PERFAI_USERNAME="$2"; shift;;
        --password) PERFAI_PASSWORD="$2"; shift;;
        --) shift ;;
    esac
    shift;
done

echo " "

### Step 1: Print Access Token ###
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


### Step 2: Retrieve Catalog ID ###
CATALOG_RESPONSE=$(curl -s --location --request GET "https://api.perfai.ai/api/v1/sensitive-data-service/apps/all?page=1&pageSize=1" \
--header "Authorization: Bearer $ACCESS_TOKEN")

CATALOG_ID=$(echo $CATALOG_RESPONSE | jq -r '.data[].catalog_id')

if [ -z "$CATALOG_ID" ]; then
    echo "Failed to retrieve catalog ID."
    echo "Response was: $CATALOG_RESPONSE"
    exit 1
fi

echo "Catalog ID is: $CATALOG_ID"
echo " "


### Step 3: Schedule Action-Run ###
RUN_RESPONSE=$(curl -s --location --request POST "https://api.perfai.ai/api/v1/api-catalog/apps/schedule-run-multiple" \
--header "Content-Type: application/json" \
--header "Authorization: Bearer $ACCESS_TOKEN" \
--data "{
    \"catalog_id\": \"${CATALOG_ID}\",
    \"services\": [\"governance\", \"vms\", \"sensitive\", \"apitest\", \"performance\"]
}")

echo "Run Response: $RUN_RESPONSE"
