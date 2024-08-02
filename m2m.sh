#!/bin/bash

TEMP=$(getopt -n "$0" -a -l "hostname:,username:,password:,api_endpoint:,openapi_spec:,governance_email:,version:,name:,source:" -- -- "$@")

     [ $? -eq 0 ] || exit

     eval set -- "$TEMP"

     while [ $# -gt 0 ] 
     do
          case "$1" in
               --hostname) PERFAI_HOSTNAME="$2"; shift;;
               --username) PERFAI_USERNAME="$2"; shift;;
               --password) PERFAI_PASSWORD="$2"; shift;;
               --api_endpoint) API_ENDPOINT="$2"; shift;;
               --openapi_spec) OPENAPI_SPEC="$2"; shift;;
               --governance_email) GOVERNANCE_EMAIL="$2"; shift;;
               --name) NAME="$2"; shift;;
               --source) SOURCE="$2"; shift;;
               --version) VERSION="$2"; shift;;
               --) shift ;;
          esac
          shift;
     done

### THIS IS FOR API REGISTRY ###
if [ "$API_ENDPOINT" = "" ];
then
API_ENDPOINT="https://api.perfai.ai"
fi

echo " "

TOKEN_RESPONSE=$(curl -s --location --request POST "$API_ENDPOINT/api/v1/auth/token" \
--header "Content-Type: application/json" \
--data-raw "{
    \"username\": \"${PERFAI_USERNAME}\",
    \"password\": \"${PERFAI_PASSWORD}\"
}")

ACCESS_TOKEN=$(echo $TOKEN_RESPONSE | jq -r '.id_token')

echo "Access Token is: $ACCESS_TOKEN"
echo " "

API_REGISTRY_RESPONSE=$(curl -s -H "Accept: application/json" -H "Content-Type: application/json" --location --request POST "$API_ENDPOINT/api/v1/api-catalog/apps/create-run" --header "Authorization: Bearer $ACCESS_TOKEN" -d "{\"openapi_spec\":\"${OPENAPI_SPEC}\",\"source\":\"${SOURCE}\",\"version\":\"${VERSION}\",\"name\":\"${NAME}\",\"governance_email\":\"${GOVERNANCE_EMAIL}\"}")

echo "API Registry Successfully: $API_REGISTRY_RESPONSE"
