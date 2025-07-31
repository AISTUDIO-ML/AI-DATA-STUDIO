#!/bin/bash

# Check for AWS CLI
if ! command -v aws &> /dev/null
then
    echo "AWS CLI not found. Please install it first."
    exit 1
fi

# Check for required argument
if [ -z "$1" ]; then
  echo "Usage: $0 <IAM_USER_NAME>"
  exit 1
fi

IAM_USER_NAME=$1
POLICY_ARN="arn:aws:iam::aws:policy/AdministratorAccess"

# Create IAM user
echo "Creating IAM user: $IAM_USER_NAME"
aws iam create-user --user-name "$IAM_USER_NAME"

# Create access key
echo "Creating access key for user: $IAM_USER_NAME"
ACCESS_KEYS=$(aws iam create-access-key --user-name "$IAM_USER_NAME")

# Extract credentials
AWS_ACCESS_KEY_ID=$(echo $ACCESS_KEYS | jq -r '.AccessKey.AccessKeyId')
AWS_SECRET_ACCESS_KEY=$(echo $ACCESS_KEYS | jq -r '.AccessKey.SecretAccessKey')

# Attach policy
echo "Attaching policy: $POLICY_ARN"
aws iam attach-user-policy --user-name "$IAM_USER_NAME" --policy-arn "$POLICY_ARN"

# Output credentials
echo ""
echo "✅ GitHub Secrets Setup:"
echo "AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID"
echo "AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY"
echo "AWS_DEFAULT_REGION=us-east-1"
