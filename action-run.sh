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

# Get commit information
COMMIT_ID=${GITHUB_SHA}
COMMIT_DATE=${Date}
COMMIT_URL="https://github.com/${GITHUB_REPOSITORY}/commit/${COMMIT_ID}"

### Step 2: Schedule AI Running ###
RUN_RESPONSE=$(curl -s --location --request POST https://api.perfai.ai/api/v1/api-catalog/apps/schedule-run-multiple \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $ACCESS_TOKEN" \
  -d "{
    \"catalog_id\": \"${CATALOG_ID}\",
    \"services\": [\"sensitive\"],
    \"buildDetails\": {
        \"commitId\": \"${COMMIT_ID}\",
        \"commitUrl\": \"${COMMIT_URL}\",
        \"commitUserName\": \"${GITHUB_ACTOR}\",
        \"commitDate\": \"${COMMIT_DATE}\",
        \"repoName\": \"${GITHUB_REPOSITORY}\"
    }
  }"
)

#echo "Run Response: $RUN_RESPONSE"

### RUN_ID Prints ###
RUN_ID=$(echo "$RUN_RESPONSE" | jq -r '.run_ids.sensitive')

echo " "
echo "Run Response: $RUN_RESPONSE"
echo " "
echo "Run ID is: $RUN_ID"

if [ -z "$RUN_ID" ]; then
  echo "Error: Run ID not found in the response"
  exit 1
fi

### Step 3: Check the wait-for-completion flag ###
if [ "$WAIT_FOR_COMPLETION" == "true" ]; then
    echo "Waiting for AI Running to complete..."

    STATUS="in_progress"

    ### Step 4: Poll the status of the AI run until completion ###
    while [[ "$STATUS" == "in_progress" ]]; do
        # Wait for 60 seconds before checking the status
        sleep 60
        
        # Check the status of the AI Running
    STATUS_RESPONSE=$(curl -s --location --request GET "https://api.perfai.ai/api/v1/sensitive-data-service/apps/get-run-status?run_id=$RUN_ID" \
      --header "Authorization: Bearer $ACCESS_TOKEN")    

    STATUS=$(echo "$STATUS_RESPONSE")

    echo "AI Running Status: $STATUS"

    # If the AI Run fails, exit with an Error
        if [[ "$STATUS" == "failed" ]]; then
            echo "Error: AI Running failed for Run ID $RUN_ID"
            exit 1
        fi
    done

    # Once the status is no longer "in_progress", assume it completed
   echo "AI Running for Catalog ID $CATALOG_ID has completed successfully!"
 else
   echo "AI Running triggered. Run ID: $RUN_ID. Exiting without waiting for completion."
 fi
