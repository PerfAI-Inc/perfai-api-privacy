#!/bin/bash

# Parse command-line arguments
TEMP=$(getopt -n "$0" -a -l "hostname:,username:,password:,openapi_spec:,governance_email:,version:,label:,base_path:,source:" -- -- "$@")

if [ $? -ne 0 ]; then
    echo "Error parsing options." >&2
    exit 1
fi

eval set -- "$TEMP"

# Initialize variables
while [ $# -gt 0 ]; do
    case "$1" in
        --hostname) PERFAI_HOSTNAME="$2"; shift;;
        --username) PERFAI_USERNAME="$2"; shift;;
        --password) PERFAI_PASSWORD="$2"; shift;;
        --openapi_spec) OPENAPI_SPEC="$2"; shift;;
        --governance_email) GOVERNANCE_EMAIL="$2"; shift;;
        --label) LABEL="$2"; shift;;
        --source) SOURCE="$2"; shift;;
        --version) VERSION="$2"; shift;;
        --base_path) BASE_PATH="$2"; shift;;
        --) shift;;
    esac
    shift
done

# Ensure required variables are set
if [[ -z "$PERFAI_USERNAME" || -z "$PERFAI_PASSWORD" ]]; then
    echo "Username and password are required." >&2
    exit 1
fi

### Step 1: Print Access Token ###
TOKEN_RESPONSE=$(curl -s --location --request POST "https://api.perfai.ai/api/v1/auth/token" \
--header "Content-Type: application/json" \
--data-raw "{
    \"username\": \"${PERFAI_USERNAME}\",
    \"password\": \"${PERFAI_PASSWORD}\"
}")

ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.id_token')

# Check if access token was retrieved successfully
if [[ "$ACCESS_TOKEN" == "null" || -z "$ACCESS_TOKEN" ]]; then
    echo "Failed to retrieve access token. Response: $TOKEN_RESPONSE" >&2
    exit 1
fi

echo "Access Token is: $ACCESS_TOKEN"
echo " "

### Step 2: Register API ###
API_REGISTRY_RESPONSE=$(curl -s -H "Accept: application/json" -H "Content-Type: application/json" \
--location --request POST "https://api.perfai.ai/api/v1/api-catalog/apps/create-run" \
--header "Authorization: Bearer $ACCESS_TOKEN" \
-d "{
    \"openapi_spec\":\"${OPENAPI_SPEC}\",
    \"source\":\"${SOURCE}\",
    \"base_path\":\"${BASE_PATH}\",
    \"version\":\"${VERSION}\",
    \"label\":\"${LABEL}\",
    \"governance_email\":\"${GOVERNANCE_EMAIL}\"
}")

# Check if API registration was successful
if echo "$API_REGISTRY_RESPONSE" | jq -e '.error' > /dev/null; then
    echo "API Registry failed: $API_REGISTRY_RESPONSE" >&2
    exit 1
else
    echo "API Registry Successfully: $API_REGISTRY_RESPONSE"
fi
