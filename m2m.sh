#!/bin/bash

TEMP=$(getopt -n "$0" -a -l "hostname:,username:,password:,api_endpoint:,openapi_spec:,governance_email:,version:,name:,source:,client_id:,client_secret:" -- -- "$@")

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
               --client_id) CLIENT_ID="$2"; shift;;
               --client_secret) CLIENT_SECRET="$2"; shift;;
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

# Step 1: Exchange the authorization code for an access token
TOKEN_RESPONSE=$(curl -s --request POST \
  --url 'https://dev-y3450b42cwy8vyl1.us.auth0.com/oauth/token' \
  --header 'content-type: application/x-www-form-urlencoded' \
  --data "grant_type=password" \
  --data "username=$PERFAI_USERNAME" \
  --data "password=$PERFAI_PASSWORD" \
  --data "audience=https://dev-y3450b42cwy8vyl1.us.auth0.com/api/v2/" \
  --data "scope=openid profile email" \
  --data "client_id=$CLIENT_ID" \
  --data "client_secret=$CLIENT_SECRET")

ACCESS_TOKEN=$(echo $TOKEN_RESPONSE | jq -r '.id_token')

echo "Access Token is: $ACCESS_TOKEN"
echo " "

API_REGISTRY_RESPONSE=$(curl -s -H "Accept: application/json" -H "Content-Type: application/json" --location --request POST "$API_ENDPOINT/api/v1/api-catalog/apps/create-run" --header "Authorization: Bearer $ACCESS_TOKEN" -d "{\"openapi_spec\":\"${OPENAPI_SPEC}\",\"source\":\"${SOURCE}\",\"version\":\"${VERSION}\",\"name\":\"${NAME}\",\"governance_email\":\"${GOVERNANCE_EMAIL}\"}")

echo "API Registry Response: $API_REGISTRY_RESPONSE"
