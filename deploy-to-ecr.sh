#!/bin/bash

# ECR Deployment Script for MediChat Pro
# This script builds and pushes the Docker image to ECR

# Configuration
AWS_REGION="us-east-1"
ECR_REPOSITORY="medichat-pro"
IMAGE_TAG="latest"

# Get AWS Account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# ECR Registry URL
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
ECR_URI="${ECR_REGISTRY}/${ECR_REPOSITORY}"

echo "🚀 Starting ECR deployment for MediChat Pro..."
echo "📦 ECR Registry: ${ECR_REGISTRY}"
echo "🏷️  Repository: ${ECR_REPOSITORY}"
echo "🏷️  Tag: ${IMAGE_TAG}"

# Step 1: Create ECR repository if it doesn't exist
echo "📋 Step 1: Creating ECR repository..."
aws ecr create-repository \
    --repository-name ${ECR_REPOSITORY} \
    --region ${AWS_REGION} \
    --image-scanning-configuration scanOnPush=true \
    --encryption-configuration encryptionType=AES256 \
    2>/dev/null || echo "✅ Repository already exists"

# Step 2: Login to ECR
echo "🔐 Step 2: Logging in to ECR..."
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}

# Step 3: Build Docker image
echo "🔨 Step 3: Building Docker image..."
docker build -t ${ECR_REPOSITORY}:${IMAGE_TAG} .

# Step 4: Tag image for ECR
echo "🏷️  Step 4: Tagging image for ECR..."
docker tag ${ECR_REPOSITORY}:${IMAGE_TAG} ${ECR_URI}:${IMAGE_TAG}

# Step 5: Push image to ECR
echo "📤 Step 5: Pushing image to ECR..."
docker push ${ECR_URI}:${IMAGE_TAG}

echo "✅ Deployment completed successfully!"
echo "🎯 ECR Image URI: ${ECR_URI}:${IMAGE_TAG}"
echo ""
echo "📋 Next steps:"
echo "1. Go to AWS App Runner console"
echo "2. Create new service"
echo "3. Select 'Container image' as source"
echo "4. Use this image URI: ${ECR_URI}:${IMAGE_TAG}"
echo "5. Add environment variables in App Runner console"
