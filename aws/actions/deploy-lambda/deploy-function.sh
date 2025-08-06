#!/bin/bash

# Lambda Deployment Script
# This script handles the deployment of Lambda functions with timeout and error handling

set -e  # Exit on any error

# Input parameters
FUNCTION_NAME="$1"
DEPLOYMENT_PACKAGE="$2"
S3_BUCKET="$3"
S3_KEY="$4"
DEPLOYMENT_TIMEOUT="$5"

echo "🚀 Starting Lambda deployment..."
echo "Function: $FUNCTION_NAME"

if [[ -n "$S3_BUCKET" ]]; then
  echo "📦 Deploying from S3..."
  echo "S3 Bucket: $S3_BUCKET"
  echo "S3 Key: $S3_KEY"
  
  # Deploy with timeout
  timeout "$DEPLOYMENT_TIMEOUT" aws lambda update-function-code \
    --function-name "$FUNCTION_NAME" \
    --s3-bucket "$S3_BUCKET" \
    --s3-key "$S3_KEY" || {
    echo "❌ Deployment failed or timed out after $DEPLOYMENT_TIMEOUT seconds"
    exit 1
  }
  
else
  echo "📦 Deploying from local file..."
  echo "Package: $DEPLOYMENT_PACKAGE"
  
  if [[ ! -f "$DEPLOYMENT_PACKAGE" ]]; then
    echo "❌ Deployment package not found: $DEPLOYMENT_PACKAGE"
    exit 1
  fi
  
  # Deploy with timeout
  timeout "$DEPLOYMENT_TIMEOUT" aws lambda update-function-code \
    --function-name "$FUNCTION_NAME" \
    --zip-file "fileb://$DEPLOYMENT_PACKAGE" || {
    echo "❌ Deployment failed or timed out after $DEPLOYMENT_TIMEOUT seconds"
    exit 1
  }
fi

echo "✅ Function code updated successfully"
