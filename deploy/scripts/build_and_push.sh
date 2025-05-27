#!/bin/bash

# Script to build Docker image, login to ECR and push the image
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


AWS_ACCOUNT_ID=$(yq '.aws.accountId' "$CONFIG_FILE")
AWS_REGION=$(yq '.aws.region' "$CONFIG_FILE")
REPO_NAME=$(yq '.aws.ecr.repository.name' "$CONFIG_FILE")
REPO_TAG=$(yq '.aws.ecr.repository.tag' "$CONFIG_FILE")

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

REPO_URI="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME"
FULL_IMAGE_NAME="$REPO_URI:$REPO_TAG"


APP_DIR="$(dirname "$0")/../../speed_calculator"
cd "$APP_DIR" || { echo "Error: Could not navigate to app directory"; exit 1; }

echo "Building Docker image..."
docker build  -t "$REPO_NAME:$REPO_TAG" --platform linux/amd64 .

echo "Tagging image as $FULL_IMAGE_NAME..."
docker tag "$REPO_NAME:$REPO_TAG" "$FULL_IMAGE_NAME"

echo "Logging in to ECR..."
aws ecr get-login-password --region "$AWS_REGION" | docker login --username AWS --password-stdin "$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"

echo "Pushing image to ECR..."
docker push "$FULL_IMAGE_NAME"

echo "Image successfully pushed to $FULL_IMAGE_NAME"