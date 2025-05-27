# Speed Calculator Deployment Guide
This directory includes scripts required to deploy the speec calculator application in AWS ECS ( Elastic container service)

You need 'yq' to run this setup. 
https://github.com/mikefarah/yq

# VPC requirements. 
We need a vpc with below configurations to run this deployment. 
A. Two public subents to deploy the load balancer
B. Two Private subents to deploy ECS tasks. 
C. Following VPC end points
https://docs.aws.amazon.com/AmazonECS/latest/developerguide/vpc-endpoints.html

### Step 01. 
configure the 'config.yaml'. This file is used to get your applciation configurations and AWS accoutn configurations. 


### Step 02.
run the scripts/create_ecr_repo.sh script. This script will check whether correct ECR repositories exists in the account. If not it will create the required ECr repository. 

### Step 03.
run scripts/build_and_push.sh scripts to build and push application container to ECR. 


### Step 04. 
run /scripts/deploy_ecs_service.sh script to deploy the applciation in ECS fargate. 

