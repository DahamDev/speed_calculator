#!/bin/bash

# Script to check and create ECR repository if it doesn't exist
# Reads configuration from config.yaml using yq

set -e

CONFIG_FILE="$(dirname "$0")/../config.yaml"



if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: Config file not found at $CONFIG_FILE"
  exit 1
fi


if ! command -v yq &> /dev/null; then
  echo "Error: yq is not installed. Please install it with: brew install yq"
  exit 1
fi


echo "Reading configuration from $CONFIG_FILE..."
AWS_ACCOUNT_ID=$(yq '.aws.accountId' "$CONFIG_FILE")
AWS_REGION=$(yq '.aws.region' "$CONFIG_FILE")
REPO_NAME=$(yq '.aws.ecr.repository.name' "$CONFIG_FILE")


if [ "$AWS_ACCOUNT_ID" = "null" ] || [ -z "$AWS_ACCOUNT_ID" ]; then
  echo "Error: AWS Account ID not found in config file"
  exit 1
fi

if [ "$AWS_REGION" = "null" ] || [ -z "$AWS_REGION" ]; then
  echo "Error: AWS Region not found in config file"
  exit 1
fi

if [ "$REPO_NAME" = "null" ] || [ -z "$REPO_NAME" ]; then
  echo "Error: ECR Repository name not found in config file"
  exit 1
fi

echo "Using AWS Account ID: $AWS_ACCOUNT_ID"
echo "Using AWS Region: $AWS_REGION"
echo "Using ECR Repository Name: $REPO_NAME"


export AWS_DEFAULT_REGION=$AWS_REGION


echo "Checking if ECR repository $REPO_NAME exists..."
if aws ecr describe-repositories --repository-names "$REPO_NAME" 2>/dev/null; then
  echo "Repository $REPO_NAME already exists."
else
  echo "Repository $REPO_NAME does not exist. Creating..."
  aws ecr create-repository --repository-name "$REPO_NAME" --image-scanning-configuration scanOnPush=true
  echo "Repository created successfully."
fi


REPO_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME"
echo "Repository URI: $REPO_URI"

echo "Completed succesfully!"