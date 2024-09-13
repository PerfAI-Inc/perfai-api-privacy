#!/bin/bash

# Default values
WAIT_FOR_COMPLETION=false

# Parse the input arguments
TEMP=$(getopt -n "$0" -a -l "hostname:,username:,password:,catalog-id:,wait-for-completion:" -- -- "$@")

[ $? -eq 0 ] || exit

eval set -- "$TEMP"

while [ $# -gt 0 ]
do
    case "$1" in
        --hostname) PERFAI_HOSTNAME="$2"; shift;;
        --username) PERFAI_USERNAME="$2"; shift;;
        --password) PERFAI_PASSWORD="$2"; shift;;
        --catalog-id) CATALOG_ID="$2"; shift;;
        --wait-for-completion) WAIT_FOR_COMPLETION="$2"; shift;;
        --) shift ;;
    esac
    shift;
done

echo " "

if [ "$PERFAI_HOSTNAME" = "" ];
then
PERFAI_HOSTNAME="https://app.apiprivacy.com"
fi

### Step 1: Print Access Token ###
TOKEN_RESPONSE=$(curl -s --location --request POST "https://api.perfai.ai/api/v1/auth/token" \
--header "Content-Type: application/json" \
--data-raw "{
    \"username\": \"${PERFAI_USERNAME}\",
    \"password\": \"${PERFAI_PASSWORD}\"
}")

ACCESS_TOKEN=$(echo $TOKEN_RESPONSE | jq -r '.id_token')

if [ -z "$ACCESS_TOKEN" ]; then
    echo "Error: Could not retrieve access token"
    exit 1
fi

echo "Access Token is: $ACCESS_TOKEN"
echo " "

### Step 2: Trigger the AI Running ###
RUN_RESPONSE=$(curl -s --location --request POST "https://api.perfai.ai/api/v1/api-catalog/apps/schedule-run-multiple" \
--header "Content-Type: application/json" \
--header "Authorization: Bearer $ACCESS_TOKEN" \
--data-raw "{
    \"catalog_id\": \"${CATALOG_ID}\",
    \"services\": [\"sensitive\"]
}")

#echo "Run Response: $RUN_RESPONSE"

RUN_ID=$(echo "$RUN_RESPONSE" | jq -r '.run_id')

if [ -z "$RUN_ID" ]; then
    echo "Error: Failed to start AI Running for Catalog ID $CATALOG_ID"
    exit 1
fi

echo "AI Running started for Catalog ID $CATALOG_ID"
echo " "

### Step 3: Check the wait-for-completion flag ###
if [ "$WAIT_FOR_COMPLETION" == "true" ]; then
    echo "Waiting for AI Running to complete..."

    STATUS="in_progress"

    ### Step 4: Poll the status of the AI run until completion ###
    while [[ "$STATUS" == "in_progress" ]]; do
        # Wait for 30 seconds before checking the status
        sleep 60
        
        # # Check the status of the AI Running
        # STATUS_RESPONSE=$(curl -s --location --request POST "https://api.perfai.ai/api/v1/sensitive-data-service/apps/run-status?run_id=${RUN_ID}" \
        #     --header "Authorization: Bearer $ACCESS_TOKEN")

        # STATUS=$(echo "$STATUS_RESPONSE" | jq -r '.status')
        # MESSAGE=$(echo "$STATUS_RESPONSE" | jq -r '.message')

        # echo "AI Running Status: $STATUS - $MESSAGE"

        # if [[ "$STATUS" == "failed" ]]; then
        #     echo "Error: AI Running failed for Run ID $RUN_ID"
        #     exit 1
        # fi
    done

    echo "AI Running for Catalog ID $CATALOG_ID has completed successfully!"
    # echo "Privacy Test for $CATALOG_ID in Progress. This may take several minutes to complete."
else
    echo "AI Running triggered. Run ID: $RUN_ID. Exiting without waiting for completion."
fi
