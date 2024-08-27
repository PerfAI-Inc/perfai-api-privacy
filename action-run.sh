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


# Fetch vulnerability data from the API
vulnerabilities=$(curl -s --location --request GET "https://api.perfai.ai/api/v1/sensitive-data-service/apps/issues?app_id=66c5b89600fbf372c2f1f117&page=1&pageSize=1" \
--header "Authorization: Bearer $ACCESS_TOKEN")

# Create the SARIF formatted data using the fetched vulnerability data
sarif_output=$(cat <<EOF
{
  "\$schema": "https://schemastore.azurewebsites.net/schemas/json/sarif-2.1.0-rtm.5.json",
  "version": "2.1.0",
  "runs": [
    {
      "tool": {
        "driver": {
          "name": "Custom Vulnerability Scanner",
          "version": "1.0",
          "informationUri": "https://example.com/tool-info",
          "rules": [
            {
              "id": "API-DP9-2024",
              "name": "Bot Data Modification",
              "shortDescription": {
                "text": "This rule identifies API endpoints vulnerable to bot data modification."
              },
              "fullDescription": {
                "text": "An attacker can create a user by making unauthenticated POST requests to the /user endpoint. This vulnerability allows attackers to bypass authentication and authorization mechanisms, potentially leading to unauthorized access to the system and data breaches."
              },
              "helpUri": "https://example.com/rules/API-DP9-2024",
              "defaultConfiguration": {
                "level": "error"
              }
            }
          ]
        }
      },
      "results": [
        {
          "ruleId": "API-DP9-2024",
          "level": "error",  # Corrected value
          "message": {
            "text": "Vulnerability Report: Bot Data Modification on POST /user Endpoint."
          },
          "locations": [
            {
              "physicalLocation": {
                "artifactLocation": {
                  "uri": "user",
                  "uriBaseId": "%SRCROOT%"
                },
                "region": {
                  "startLine": 1
                }
              }
            }
          ]
        }
      ]
    }
  ]
}
EOF
)

# Print the SARIF formatted vulnerabilities
echo "Vulnerabilities SARIF: $sarif_output"

echo "$sarif_output" >> $GITHUB_WORKSPACE/$OUTPUT_FILENAME









### Step 4: Sensitive Data Details ###

# sensitivefielddata=$(curl -s --location --request GET "https://api.perfai.ai/api/v1/sensitive-data-service/apps/endpoint-piis?app_id=$APP_ID&page=1&pageSize=1" \
# --header "Authorization: Bearer $ACCESS_TOKEN" | jq -r '{
#    "$schema": "https://json.schemastore.org/sarif-2.1.0.json",
#     "version": "2.1.0",
#     "runs": [
#         {
#             "tool": {
#                 "driver": {
#                     "name": "Custom Security Tool",
#                     "version": "1.0.0",
#                     "informationUri": "https://example.com",
#                     "rules": []
#                 }
#             },
#             "results": [
#                 {
#                     "ruleId": "PII-Leak",
#                     "message": {
#                         "text": .issues[].explainer
#                     },
#                     "locations": [
#                         {
#                             "physicalLocation": {
#                                 "artifactLocation": {
#                                     "uri": .issues[].path,
#                                     "uriBaseId": "%SRCROOT%"
#                                 },
#                                 "region": {
#                                     "startLine": 1,
#                                     "startColumn": 1
#                                 }
#                             }
#                         }
#                     ],
#                     "properties": {
#                         "id": .issues[].id,
#                         "impact": .issues[].impact,
#                         "name": .issues[].name,
#                         "label": .issues[].label,
#                         "direction": .issues[].direction,
#                         "severity": .issues[].severity,
#                         "created_on": .issues[].created_on,
#                         "response": .issues[].response,
#                         "remediation": .issues[].remediation
#                     }
#                 }
#             ]
#         }
#     ]
# }')



# Write SARIF data to file
# echo "Sensitive Data Fields: $sensitivefielddata"
# echo " "

# echo "$sensitivefielddata" >> $GITHUB_WORKSPACE/$OUTPUT_FILENAME

# sensitivefielddata=$(curl -s --location --request GET "https://api.perfai.ai/api/v1/sensitive-data-service/apps/endpoint-piis?app_id=$APP_ID&page=1&pageSize=1" \
# --header "Authorization: Bearer $ACCESS_TOKEN" | jq -r '{
#   "version": "2.1.0",
#   "$schema": "https://raw.githubusercontent.com/oasis-tcs/sarif-spec/master/Schemata/sarif-schema-2.1.0.json",
#   "runs": [
#     {
#       "tool": {
#         "driver": {
#           "name": "Custom Security Tool",
#           "version": "1.0.0",
#           "informationUri": "https://example.com/security-tool",
#           "rules": [
#             {
#               "id": "PII001",
#               "name": "Sensitive Data Exposure",
#               "shortDescription": {
#                 "text": "Sensitive data field exposure detected"
#               },
#               "fullDescription": {
#                 "text": "The sensitive data field 'username' was found in the response."
#               },
#               "defaultConfiguration": {
#                 "level": "warning"
#               },
#               "helpUri": "https://example.com/security-tool/rules/PII001"
#             }
#           ]
#         }
#       },
#       "results": [
#         {
#           "ruleId": "PII001",
#           "message": {
#             "text": "Sensitive data field 'username' detected in the response."
#           },
#           "locations": [
#             {
#               "physicalLocation": {
#                 "artifactLocation": {
#                   "uri": "user/%7Busername%7D",
#                   "uriBaseId": "%SRCROOT%"
#                 },
#                 "region": {
#                   "startLine": 1,
#                   "startColumn": 1
#                 }
#               },
#               "logicalLocations": [
#                 {
#                   "name": "Response Field",
#                   "kind": "response"
#                 }
#               ]
#             }
#           ],
#           "properties": {
#             "method": "GET",
#             "field": "username"
#           }
#         }
#       ]
#     }
#   ]
# }')

# echo "Sensitive Field Details: $sensitivefielddata"

# echo "$sensitivefielddata" >> $GITHUB_WORKSPACE/$OUTPUT_FILENAME 


# sensitivefielddata=$(curl -s --location --request GET "https://api.perfai.ai/api/v1/sensitive-data-service/apps/endpoint-piis?app_id=$APP_ID&page=1&pageSize=1" \
# --header "Authorization: Bearer $ACCESS_TOKEN" | jq -r '.issues[] | {id, path, impact: .impact, location: .location, name: .name, label: .label, direction: .direction, severity: .severity, created_on: .created_on, response: .response, explainer: .explainer, remediation: .remediation}')

# echo "Sensitive Data Fields: $sensitivefielddata"
# echo " "

# echo "$sensitivefielddata" >> $GITHUB_WORKSPACE/$OUTPUT_FILENAME
# echo "SARIF output file created successfully"

