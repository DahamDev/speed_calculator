#!/bin/bash

# Script to deploy ECS service using CloudFormation template

set -e

CONFIG_FILE="$(dirname "$0")/../config.yaml"
CFN_TEMPLATE="$(dirname "$0")/../cfn-ecs-service.yaml"
STACK_NAME="speed-calculator-stack"


if [ ! -f "$CONFIG_FILE" ]; then
  echo "Error: Config file not found at $CONFIG_FILE"
  exit 1
fi

if [ ! -f "$CFN_TEMPLATE" ]; then
  echo "Error: CloudFormation template not found at $CFN_TEMPLATE"
  exit 1
fi


if ! command -v yq &> /dev/null; then
  echo "Error: yq is not installed. Please install it with: brew install yq"
  exit 1
fi


echo "Reading configuration from $CONFIG_FILE..."
AWS_ACCOUNT_ID=$(yq '.aws.accountId' "$CONFIG_FILE")
AWS_REGION=$(yq '.aws.region' "$CONFIG_FILE")
VPC_ID=$(yq '.aws.vpc.id' "$CONFIG_FILE")
REPO_NAME=$(yq '.aws.ecr.repository.name' "$CONFIG_FILE")
CONTAINER_PORT=$(yq '.app.environment.API_PORT' "$CONFIG_FILE")
LOG_LEVEL=$(yq '.app.environment.LOG_LEVEL' "$CONFIG_FILE")
REPO_TAG=$(yq '.aws.ecr.repository.tag' "$CONFIG_FILE")

PUBLIC_SUBNET_1=$(yq '.aws.vpc.public_subnets[0].id' "$CONFIG_FILE")
PUBLIC_SUBNET_2=$(yq '.aws.vpc.public_subnets[1].id' "$CONFIG_FILE")
PRIVATE_SUBNET_1=$(yq '.aws.vpc.private_subnets[0].id' "$CONFIG_FILE")
PRIVATE_SUBNET_2=$(yq '.aws.vpc.private_subnets[1].id' "$CONFIG_FILE")


if [ "$VPC_ID" = "null" ] || [ -z "$VPC_ID" ]; then
  echo "Error: VPC ID not found in config file"
  exit 1
fi

if [ "$PUBLIC_SUBNET_1" = "null" ] || [ -z "$PUBLIC_SUBNET_1" ] || [ "$PUBLIC_SUBNET_2" = "null" ] || [ -z "$PUBLIC_SUBNET_2" ]; then
  echo "Error: Public subnet IDs not found in config file"
  exit 1
fi

if [ "$PRIVATE_SUBNET_1" = "null" ] || [ -z "$PRIVATE_SUBNET_1" ] || [ "$PRIVATE_SUBNET_2" = "null" ] || [ -z "$PRIVATE_SUBNET_2" ]; then
  echo "Error: Private subnet IDs not found in config file"
  exit 1
fi

if [ "$CONTAINER_PORT" = "null" ] || [ -z "$CONTAINER_PORT" ]; then
  echo "Error: Container port not found in config file"
  exit 1
fi

if [ "$REPO_NAME" = "null" ] || [ -z "$REPO_NAME" ]; then
  echo "Error: ECR repository name not found in config file"
  exit 1
fi


CONTAINER_IMAGE="$AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$REPO_NAME:$REPO_TAG"

echo "Deploying CloudFormation stack with the following parameters:"
echo "  VPC ID: $VPC_ID"
echo "  Public Subnets: $PUBLIC_SUBNET_1,$PUBLIC_SUBNET_2"
echo "  Private Subnets: $PRIVATE_SUBNET_1,$PRIVATE_SUBNET_2"
echo "  Container Image: $CONTAINER_IMAGE"
echo "  Container Port: $CONTAINER_PORT"
echo "  Log Level: $LOG_LEVEL"


aws cloudformation deploy \
  --template-file "$CFN_TEMPLATE" \
  --stack-name "$STACK_NAME" \
  --parameter-overrides \
    EnvironmentName="dev" \
    VpcId="$VPC_ID" \
    PublicSubnets="$PUBLIC_SUBNET_1,$PUBLIC_SUBNET_2" \
    PrivateSubnets="$PRIVATE_SUBNET_1,$PRIVATE_SUBNET_2" \
    ContainerImage="$CONTAINER_IMAGE" \
    ContainerPort="$CONTAINER_PORT" \
    LogLevel="$LOG_LEVEL" \
  --capabilities CAPABILITY_NAMED_IAM


echo "Stack deployment complete. Fetching outputs..."
aws cloudformation describe-stacks \
  --stack-name "$STACK_NAME" \
  --query "Stacks[0].Outputs" \
  --output table

echo "Deployment completed successfully!"