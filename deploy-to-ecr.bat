@echo off
REM ECR Deployment Script for MediChat Pro (Windows)
REM This script builds and pushes the Docker image to ECR

REM Configuration
set AWS_REGION=us-east-1
set ECR_REPOSITORY=medichat-pro
set IMAGE_TAG=latest

echo 🚀 Starting ECR deployment for MediChat Pro...

REM Get AWS Account ID
for /f %%i in ('aws sts get-caller-identity --query Account --output text') do set AWS_ACCOUNT_ID=%%i

REM ECR Registry URL
set ECR_REGISTRY=%AWS_ACCOUNT_ID%.dkr.ecr.%AWS_REGION%.amazonaws.com
set ECR_URI=%ECR_REGISTRY%/%ECR_REPOSITORY%

echo 📦 ECR Registry: %ECR_REGISTRY%
echo 🏷️  Repository: %ECR_REPOSITORY%
echo 🏷️  Tag: %IMAGE_TAG%

REM Step 1: Create ECR repository if it doesn't exist
echo 📋 Step 1: Creating ECR repository...
aws ecr create-repository --repository-name %ECR_REPOSITORY% --region %AWS_REGION% --image-scanning-configuration scanOnPush=true --encryption-configuration encryptionType=AES256 2>nul || echo ✅ Repository already exists

REM Step 2: Login to ECR
echo 🔐 Step 2: Logging in to ECR...
aws ecr get-login-password --region %AWS_REGION% | docker login --username AWS --password-stdin %ECR_REGISTRY%

REM Step 3: Build Docker image
echo 🔨 Step 3: Building Docker image...
docker build -t %ECR_REPOSITORY%:%IMAGE_TAG% .

REM Step 4: Tag image for ECR
echo 🏷️  Step 4: Tagging image for ECR...
docker tag %ECR_REPOSITORY%:%IMAGE_TAG% %ECR_URI%:%IMAGE_TAG%

REM Step 5: Push image to ECR
echo 📤 Step 5: Pushing image to ECR...
docker push %ECR_URI%:%IMAGE_TAG%

echo ✅ Deployment completed successfully!
echo 🎯 ECR Image URI: %ECR_URI%:%IMAGE_TAG%
echo.
echo 📋 Next steps:
echo 1. Go to AWS App Runner console
echo 2. Create new service
echo 3. Select 'Container image' as source
echo 4. Use this image URI: %ECR_URI%:%IMAGE_TAG%
echo 5. Add environment variables in App Runner console

pause
