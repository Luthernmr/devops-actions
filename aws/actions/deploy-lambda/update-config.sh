#!/bin/bash

# Lambda Configuration Update Script
# This script handles updating Lambda function configuration

set -e  # Exit on any error

# Input parameters
FUNCTION_NAME="$1"
RUNTIME="$2"
HANDLER="$3"
TIMEOUT="$4"
MEMORY_SIZE="$5"
ENVIRONMENT_VARIABLES="$6"

echo "⚙️  Updating Lambda function configuration..."

UPDATE_ARGS=""

if [[ -n "$RUNTIME" ]]; then
  UPDATE_ARGS="$UPDATE_ARGS --runtime $RUNTIME"
  echo "Runtime: $RUNTIME"
fi

if [[ -n "$HANDLER" ]]; then
  UPDATE_ARGS="$UPDATE_ARGS --handler $HANDLER"
  echo "Handler: $HANDLER"
fi

if [[ -n "$TIMEOUT" ]]; then
  UPDATE_ARGS="$UPDATE_ARGS --timeout $TIMEOUT"
  echo "Timeout: $TIMEOUT seconds"
fi

if [[ -n "$MEMORY_SIZE" ]]; then
  UPDATE_ARGS="$UPDATE_ARGS --memory-size $MEMORY_SIZE"
  echo "Memory: $MEMORY_SIZE MB"
fi

if [[ -n "$ENVIRONMENT_VARIABLES" ]]; then
  UPDATE_ARGS="$UPDATE_ARGS --environment Variables='$ENVIRONMENT_VARIABLES'"
  echo "Environment variables updated"
fi

if [[ -n "$UPDATE_ARGS" ]]; then
  echo "Applying configuration changes..."
  timeout 60 aws lambda update-function-configuration \
    --function-name "$FUNCTION_NAME" \
    $UPDATE_ARGS || {
    echo "❌ Configuration update failed or timed out"
    exit 1
  }
  echo "✅ Configuration updated successfully"
else
  echo "ℹ️  No configuration updates specified"
fi
