#!/bin/bash

# Check for required input
if [ -z "$1" ]; then
  echo "Usage: $0 <subscription_id> [resource_group_name]"
  exit 1
fi

SUBSCRIPTION_ID=$1
RESOURCE_GROUP_NAME=$2
SP_NAME="AIDataStudioSP"

# Login to Azure (assumes user is already logged in or using managed identity)
echo "Setting subscription to $SUBSCRIPTION_ID..."
az account set --subscription "$SUBSCRIPTION_ID"

# Determine scope
if [ -z "$RESOURCE_GROUP_NAME" ]; then
  SCOPE="/subscriptions/$SUBSCRIPTION_ID"
else
  SCOPE="/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP_NAME"
fi

# Create service principal
echo "Creating service principal '$SP_NAME' with Contributor role scoped to $SCOPE..."
SP_OUTPUT=$(az ad sp create-for-rbac --name "$SP_NAME" --role contributor --scopes "$SCOPE" --sdk-auth)

# Output credentials for GitHub Secrets
echo "Service principal created successfully."
echo "Use the following values for GitHub Secrets:"
echo "-------------------------------------------"
echo "AZURE_CLIENT_ID:     $(echo $SP_OUTPUT | jq -r .clientId)"
echo "AZURE_CLIENT_SECRET: $(echo $SP_OUTPUT | jq -r .clientSecret)"
echo "AZURE_TENANT_ID:     $(echo $SP_OUTPUT | jq -r .tenantId)"
echo "AZURE_SUBSCRIPTION_ID: $SUBSCRIPTION_ID"
