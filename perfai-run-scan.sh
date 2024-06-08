#!/bin/bash
# Begin


TEMP=$(getopt -n "$0" -a -l "hostname:,username:,password:,openapi_spec:,governance_email:,version:,name:,source:,url:,client_id:,client_secret:,audience:,grant_type:,access_token:" -- -- "$@")
# TEMP=$(getopt -n "$0" -a -l "username:,password:,apiSpecURL:,apiBasePath:,authUrl:,authBody:,authHeaders:,licenseKey:,label:,governance_email:" -- -- "$@")
# TEMP=$(getopt -n "$0" -a -l "base_url:,auth0_url:,register_url:,username:,password:,openapi_spec:,base_path:,label:,governance_email:" -- -- "$@")

    [ $? -eq 0 ] || exit

    eval set --  "$TEMP"

    while [ $# -gt 0 ]
    do
             case "$1" in
                    --hostname) PERFAI_HOSTNAME="$2"; shift;;
                    --username) PERFAI_USER="$2"; shift;;
                    --password) PERFAI_PWD="$2"; shift;;
                    --openapi_spec) OPENAPI_SPEC="$2"; shift;;
                    --governance_email) GOVERNANCE_EMAIL="$2"; shift;;
                    --name) NAME="$2"; shift;;
                    --source) SOURCE="$2"; shift;;
                    --version) VERSION="$2"; shift;;
                    --url) URL="$2"; shift;;
                    --client_id) CLIENT_ID="$2"; shift;;
                    --client_secret) CLIENT_SECRET="$2"; shift;;
                    --audience) AUDIENCE="$2"; shift;;
                    --grant_type) GRANT_TYPE="$2"; shift;;  
                    --access_token) ACCESS_TOKEN="$2"; shift;; 
                    # --authBody) AUTH_BODY="$2"; shift;;
                    # --authUrl) AUTH_URL="$2"; shift;;
                    # --authHeaders) AUTH_HEADERS="$2"; shift;;
                    # --licenseKey) LICENSE_KEY="$2"; shift;;
                    # --label) LABEL="$2"; shift;;
                    # --email_reports) EMAIL_REPORTS="$2"; shift;;
                    --) shift ;;
             esac
             shift;
    done

# # Set defaults for configurable options
BASE_URL=${BASE_URL:-"https://app.apicontract.dev"}
AUTH0_URL=${AUTH0_URL:-"https://dev-y3450b42cwy8vyl1.us.auth0.com"}
REGISTER_URL=${REGISTER_URL:-"https://app.apicontract.dev/apis/register"}


if [ "$PERFAI_HOSTNAME" = "" ];
then
PERFAI_HOSTNAME="https://api.perfai.ai"
fi

# echo " "
# token=$(curl -s -H "Content-Type: application/json" -X POST -d '{"client_id": "'"${CLIENT_ID}"'", "client_secret": "'"${CLIENT_SECRET}"'"}' "${AUTH0_URL}"/login)
# echo "generated token is:" "$token"

echo " "
token=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'"${PERFAI_USER}"'", "password": "'"${PERFAI_PWD}"'"}' "${PERFAI_HOSTNAME}"/login)
echo "generated token is:" "$token"
echo " "

curl -s -H "Accept: application/json" -H "Content-Type: application/json" --location --request POST "${PERFAI_HOSTNAME}/api/v1/api-catalog/apps/create-run" --header "Authorization: Bearer $token" -d  '{"openapi_spec":"'"${OPENAPI_SPEC}"'","source":"'"${SOURCE}"'","version":"'"${VERSION}"'","name":"'"${NAME}"'","governance_email":"'"${GOVERNANCE_EMAIL}"'","auth0_url":"'"${AUTH0_URL}"'","register_url":"'"${REGISTER_URL}"'"}'
#DATA=$(curl -k -s -H "Accept: application/json" -H "Content-Type: application/json" --location --request POST "https://api.dev.perfai.ai/api/v1/api-catalog/apps/create-run" --header "Authorization: Bearer $token" -d  '{"base_url":"'"${BASE_URL}"'","auth0_url":"'"${AUTH0_URL}"'","register_url":"'"${REGISTER_URL}"'","openapi_spec":"'"${OPENAPI_SPEC}"'","base_path":"'"${BASEPATH_SPEC}"'","label":"'"${LABEL}"'","governance_email":"'"${GOVERNANCE_EMAIL}"'"}' | jq -r .token)
#curl -k -s -H "Accept: application/json" -H "Content-Type: application/json" --location --request POST "https://api.perfai.ai/api/v1/api-catalog/apps/create-run" --header "Authorization: Bearer $token" -d  '{"apiSpecURL":"'"${API_SPEC_URL}"'","authUrl":"'"${AUTH_URL}"'","authBody":"'"${AUTH_BODY}"'","authHeaders":"'"${AUTH_HEADERS}"'","licenseKey":"'"${LICENSE_KEY}"'","label":"'"${LABEL}"'","email_reports":"'"${EMAIL_REPORTS}"'"}'

echo "Successfully created the API Register."
