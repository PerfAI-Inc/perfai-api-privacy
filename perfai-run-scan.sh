#!/bin/bash
# Begin

TEMP=$(getopt -n "$0" -a -l "apiSpecURL:,apiBasePath:,authUrl:,authBody:,authHeaders:,licenseKey:" -- -- "$@")
# TEMP=$(getopt -n "$0" -a -l "base_url:,auth0_url:,register_url:,username:,password:,openapi_spec:,base_path:,label:,governance_email:" -- -- "$@")

    [ $? -eq 0 ] || exit

    eval set --  "$TEMP"

    while [ $# -gt 0 ]
    do
             case "$1" in
                    --base_url) BASE_URL="$2"; shift;;
                    --auth0_url) AUTH0_URL="$2"; shift;;
                    --register_url) REGISTER_URL="$2"; shift;;
                    --username) PERFAI_USER="$2"; shift;;
                    --password) PERFAI_PWD="$2"; shift;;
                    --openapi_spec) OPENAPI_SPEC="$2"; shift;;
                    --base_path) BASEPATH_SPEC="$2"; shift;;
                    --label) LABEL="$2"; shift;;
                    --governance_email) GOVERNANCE_EMAIL="$2"; shift;;
                    --) shift ;;
             esac
             shift;
    done

# # Set defaults for configurable options
BASE_URL=${BASE_URL:-"https://dev.perfai.ai"}
AUTH0_URL=${AUTH0_URL:-"https://dev-y3450b42cwy8vyl1.us.auth0.com"}
REGISTER_URL=${REGISTER_URL:-"https://dev.perfai.ai/apis/register"}


if [ "$BASE_URL" = "" ]
then
   BASE_URL="https://dev.perfai.ai"
fi    

echo " "
token=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'"${PERFAI_USER}"'", "password": "'"${PERFAI_PWD}"'"}' "${AUTH0_URL}"/login | jq -r .token)
echo "generated token is:" "$token"
echo " "

DATA=$(curl -k -s -H "Accept: application/json" -H "Content-Type: application/json" --location --request POST "https://api.dev.perfai.ai/api/v1/api-catalog/apps/create-run" --header "Authorization: Bearer $token" -d  '{"base_url":"'"${BASE_URL}"'","auth0_url":"'"${AUTH0_URL}"'","register_url":"'"${REGISTER_URL}"'","openapi_spec":"'"${OPENAPI_SPEC}"'","base_path":"'"${BASEPATH_SPEC}"'","label":"'"${LABEL}"'","governance_email":"'"${GOVERNANCE_EMAIL}"'"}' | jq -r .token)
echo "$DATA"
