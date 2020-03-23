#!/bin/bash

set -ea

##############################
# Azure AD server component
##############################

echo "Create the Azure AD application"
serverApplicationId=$(az ad app create \
    --display-name "${AKS_CLUSTER_NAME}Server" \
    --identifier-uris "https://${AKS_CLUSTER_NAME}Server" \
    --query appId -o tsv)

export SERVER_APP_ID=$serverApplicationId

echo "Update the application group memebership claims"
az ad app update --id $serverApplicationId --set groupMembershipClaims=All > /dev/null

echo "Create a service principal for the Azure AD application"
az ad sp create --id $serverApplicationId > /dev/null ||:

echo "Get the service principal secret"
serverApplicationSecret=$(az ad sp credential reset \
    --name $serverApplicationId \
    --credential-description "AKSPassword" \
    --query password -o tsv)

export SERVER_APP_SECRET=$serverApplicationSecret

# The Azure AD needs permissions to perform the following actions:
# 1. Read directory data
# 2. Sign in and read user profile
echo "Add required permissions"
az ad app permission add \
    --id $serverApplicationId \
    --api 00000003-0000-0000-c000-000000000000 \
    --api-permissions e1fe6dd8-ba31-4d61-89e7-88639da4683d=Scope 06da0dbc-49e2-44d2-8312-53f166ab848a=Scope 7ab1d382-f21e-4acd-a863-ba3e13f7da61=Role > /dev/null

echo "Grant the permissions assigned in the previous step"
az ad app permission grant --id $serverApplicationId --api 00000003-0000-0000-c000-000000000000
az ad app permission admin-consent --id  $serverApplicationId


##############################
# Azure AD client component
##############################

echo "Creating client appliction"
clientApplicationId=$(az ad app create \
    --display-name "${AKS_CLUSTER_NAME}Client" \
    --native-app \
    --reply-urls "https://${AKS_CLUSTER_NAME}Client" \
    --query appId -o tsv)

export CLIENT_APP_ID=$clientApplicationId

echo "Create a service principal for the client application"
az ad sp create --id $clientApplicationId > /dev/null ||:

echo "Get the oAuth2 ID for the server app to allow the authentication flow"
oAuthPermissionId=$(az ad app show --id $serverApplicationId --query "oauth2Permissions[0].id" -o tsv)

echo "Add the permissions for the client application and server application components to use the oAuth2"
az ad app permission add --id $clientApplicationId --api $serverApplicationId --api-permissions ${oAuthPermissionId}=Scope > /dev/null
az ad app permission grant --id $clientApplicationId --api $serverApplicationId


echo "export SERVER_APP_ID=$serverApplicationId"
echo "export SERVER_APP_SECRET=$serverApplicationSecret"
echo "export CLIENT_APP_ID=$clientApplicationId"
echo ""