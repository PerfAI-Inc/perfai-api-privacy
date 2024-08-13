#!/bin/bash

TEMP=$(getopt -n "$0" -a -l "hostname:,username:,password:,outputfile:" -- -- "$@")

[ $? -eq 0 ] || exit

eval set -- "$TEMP"

while [ $# -gt 0 ]
do
    case "$1" in
        --hostname) PERFAI_HOSTNAME="$2"; shift;;
        --username) PERFAI_USERNAME="$2"; shift;;
        --password) PERFAI_PASSWORD="$2"; shift;;
        --outputfile) OUTPUT_FILENAME="$2"; shift;;
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


### Step 2: Retrieve Catalog and App ID ###
CATALOG_RESPONSE=$(curl -s --location --request GET "https://api.perfai.ai/api/v1/sensitive-data-service/apps/all?page=1&pageSize=1" \
--header "Authorization: Bearer $ACCESS_TOKEN")

CATALOG_ID=$(echo $CATALOG_RESPONSE | jq -r '.data[].catalog_id')
APP_ID=$(echo $CATALOG_RESPONSE | jq -r '.data[]._id')

if [ -z "$CATALOG_ID" ]; then
    echo "Failed to retrieve catalog ID."
    echo "Response was: $CATALOG_RESPONSE"
fi

if [ -z "$APP_ID" ]; then
    echo "Failed to retrieve catalog ID."
    echo "Response was: $APP_ID"
fi

echo "Catalog ID is: $CATALOG_ID"
echo "APP ID is: $APP_ID"
echo " "

### Step 3: Schedule Action-Run ###
RUN_RESPONSE=$(curl -s --location --request POST "https://api.perfai.ai/api/v1/api-catalog/apps/schedule-run-multiple" \
--header "Content-Type: application/json" \
--header "Authorization: Bearer $ACCESS_TOKEN" \
--data-raw "{
    \"catalog_id\": \"${CATALOG_ID}\",
    \"services\": [\"governance\", \"vms\", \"sensitive\", \"apitest\", \"performance\"]
}")

echo "Run Response: $RUN_RESPONSE"
echo " "

### Step 4: Sensitive Data Details ###
sensitivefielddata=$(curl -s --location --request GET "https://api.perfai.ai/api/v1/sensitive-data-service/apps/endpoint-piis?app_id=$APP_ID&page=1&pageSize=1" \
--header "Authorization: Bearer $ACCESS_TOKEN" | jq -r '{
    "$schema": "https://json.schemastore.org/sarif-2.1.0.json",
    "version": "2.1.0",
    "runs": [
        {
            "tool": {
                "driver": {
                    "name": "Custom Security Tool",
                    "version": "1.0.0",
                    "informationUri": "https://example.com",
                    "rules": []
                }
            },
            "results": [
                {
                    "ruleId": "PII-Leak",
                    "message": {
                        "text": .issues[].explainer
                    },
                    "locations": [
                        {
                            "physicalLocation": {
                                "artifactLocation": {
                                    # "uri": "file:///" + .issues[].path  # Adjust the URI as needed
                                },
                                "region": {
                                    "startLine": 1,
                                    "startColumn": 1
                                }
                            }
                        }
                    ],
                    "properties": {
                        "id": .issues[].id,
                        "impact": .issues[].impact,
                        "name": .issues[].name,
                        "label": .issues[].label,
                        "direction": .issues[].direction,
                        "severity": .issues[].severity,
                        "created_on": .issues[].created_on,
                        "response": .issues[].response,
                        "remediation": .issues[].remediation
                    }
                }
            ]
        }
    ]
}')

# Write SARIF data to file
echo "Sensitive Data Fields: $sensitivefielddata"
echo " "

echo "$sensitivefielddata" >> $GITHUB_WORKSPACE/$OUTPUT_FILENAME




# sensitivefielddata=$(curl -s --location --request GET "https://api.perfai.ai/api/v1/sensitive-data-service/apps/endpoint-piis?app_id=$APP_ID&page=1&pageSize=1" \
# --header "Authorization: Bearer $ACCESS_TOKEN" | jq -r '.issues[] | {id, path, impact: .impact, location: .location, name: .name, label: .label, direction: .direction, severity: .severity, created_on: .created_on, response: .response, explainer: .explainer, remediation: .remediation}')

# echo "Sensitive Data Fields: $sensitivefielddata"
# echo " "

# echo "$sensitivefielddata" >> $GITHUB_WORKSPACE/$OUTPUT_FILENAME
# echo "SARIF output file created successfully"

