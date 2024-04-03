# Production Ready Jenkins on Amazon ECS Using Terraform & Jenkins ConfigAsCode

This project automates the deployment of infrastructure components required for running Jenkins on AWS ECS (Elastic Container Service).

## Table of Contents

1. [Introduction](#introduction)
2. [Prerequisites](#prerequisites)
3. [Setup](#setup)
4. [Usage](#usage)
5. [Tear Down](#tear-down)

## Introduction

This project aims to simplify the deployment process of Jenkins on AWS ECS by utilizing Terraform for infrastructure provisioning and Docker for containerization. It automates the creation of necessary AWS resources such as VPC, ECR (Elastic Container Registry), ECS cluster, and associated networking configurations. Additionally, it facilitates the build and push of Docker images for Jenkins controller to ECR and manages the ECS service for Jenkins.

## Prerequisites

Before proceeding with the deployment, ensure you have the following prerequisites:

- AWS CLI installed and configured with appropriate IAM permissions.
- Terraform CLI installed (version 0.12.x or later).
- Docker installed on your local machine.
- AWS credentials and profiles properly configured.

## Setup

1. **Network Setup**: Initialize, plan, and apply the Terraform configuration for setting up the network infrastructure.

```bash
terraform -chdir=terraform/jenkins/network init
terraform -chdir=terraform/jenkins/network plan -var-file ../../vars/ap-south-1/prod/network.tfvars
terraform -chdir=terraform/jenkins/network apply -var-file ../../vars/ap-south-1/prod/network.tfvars
```

2. **ECR Setup**: Initialize, plan, and apply the Terraform configuration for setting up the Elastic Container Registry.

```bash
terraform -chdir=terraform/jenkins/ecr init
terraform -chdir=terraform/jenkins/ecr plan -var-file ../../vars/ap-south-1/prod/ecr.tfvars
terraform -chdir=terraform/jenkins/ecr apply -var-file ../../vars/ap-south-1/prod/ecr.tfvars
```

3. **Build and Push Jenkins Controller Image**: Navigate to the `dockerfiles/jenkins-controller` directory and replace AWS profile with your own and ECR output from the previous step. Then build, tag, and push the Docker image to ECR.

```bash
aws ecr get-login-password --region ap-south-1 --profile dev_aws_r_and_d_account | sudo docker login --username AWS --password-stdin <ECR-SETUP-OUTPUT-FROM-APPLY-COMMAND>
sudo docker build -t jenkins-controller:v1.0 .
sudo docker tag jenkins-controller:v1.0 <ECR-SETUP-OUTPUT-FROM-APPLY-COMMAND>/jenkins-controller:v1.0
sudo docker push <ECR-SETUP-OUTPUT-FROM-APPLY-COMMAND>/jenkins-controller:v1.0
```

4. **ECS Setup**: Initialize, plan, and apply the Terraform configuration for setting up the ECS cluster.

```bash
terraform -chdir=terraform/jenkins/ecs init
terraform -chdir=terraform/jenkins/ecs plan -var-file ../../vars/ap-south-1/prod/ecs.tfvars
terraform -chdir=terraform/jenkins/ecs apply -var-file ../../vars/ap-south-1/prod/ecs.tfvars
```

## Usage

After the setup, you can access Jenkins by navigating to the load balancer URL created during the ECS setup. Login credentials can be obtained from the ECS service outputs or configured as needed.

## Tear Down

To tear down the infrastructure, follow these steps:

1. **Destroy ECS Resources**: Run the following Terraform commands to destroy the ECS resources.

```bash
terraform -chdir=terraform/jenkins/ecs destroy -var-file ../../vars/ap-south-1/prod/ecs.tfvars
```

2. **Destroy ECR Resources**: Run the following Terraform commands to destroy the ECR resources.

```bash
terraform -chdir=terraform/jenkins/ecr destroy -var-file ../../vars/ap-south-1/prod/ecr.tfvars
```

3. **Destroy Network Resources**: Run the following Terraform commands to destroy the network resources.

```bash
terraform -chdir=terraform/jenkins/network destroy -var-file ../../vars/ap-south-1/prod/network.tfvars
```

Ensure to confirm the destruction when prompted. Be cautious as this action will permanently delete the infrastructure components.

---