#!/bin/bash

# Lambda Package Preparation Script
# This script handles the preparation of Lambda deployment packages with timeout and error handling

set -e  # Exit on any error

# Input parameters
ZIP_FILE="$1"
SOURCE_DIRECTORY="$2"
REQUIREMENTS_FILE="$3"
INSTALL_DEPENDENCIES="$4"
PACKAGE_TIMEOUT="$5"

# Function to cleanup on timeout or error
cleanup() {
  echo "🧹 Cleaning up temporary files..."
  rm -rf lambda-package lambda-deployment.zip 2>/dev/null || true
  if [[ $1 == "timeout" ]]; then
    echo "❌ Package preparation timed out after ${PACKAGE_TIMEOUT} seconds"
    exit 124
  elif [[ $1 == "error" ]]; then
    echo "❌ Package preparation failed"
    exit 1
  fi
}

# Set up timeout and error handling
trap 'cleanup error' ERR
trap 'cleanup timeout' TERM

# Start timeout in background
(
  sleep "$PACKAGE_TIMEOUT"
  echo "⏰ Package preparation timeout reached"
  kill -TERM $$ 2>/dev/null || true
) &
TIMEOUT_PID=$!

# Function to install Python dependencies
install_python_deps() {
  local req_path="$1"
  local target_dir="$2"
  
  if [[ -f "$req_path" ]]; then
    echo "📋 Installing Python dependencies from $req_path"
    echo "This may take a while depending on the number of dependencies..."
    
    # Install with timeout and progress
    timeout 60 pip install -r "$req_path" --target "$target_dir" --no-deps --upgrade --quiet || {
      echo "❌ Dependency installation failed or timed out"
      cleanup error
    }
    
    echo "✅ Dependencies installed successfully"
  else
    echo "⚠️  No requirements.txt found at $req_path, skipping dependency installation"
  fi
}

# Function to create deployment package
create_package() {
  local source_path="$1"
  local package_dir="lambda-package"
  
  echo "Creating deployment package..."
  cd "$package_dir"
  zip -r ../lambda-deployment.zip . -q
  cd ..
  
  # Check package size
  PACKAGE_SIZE=$(du -h lambda-deployment.zip | cut -f1)
  echo "📦 Package size: $PACKAGE_SIZE"
  
  # Warn if package is large
  PACKAGE_SIZE_BYTES=$(stat -f%z lambda-deployment.zip 2>/dev/null || stat -c%s lambda-deployment.zip)
  if [[ $PACKAGE_SIZE_BYTES -gt 52428800 ]]; then  # 50MB
    echo "⚠️  Warning: Package size ($PACKAGE_SIZE) exceeds 50MB. Consider optimizing dependencies."
  fi
  
  if [[ $PACKAGE_SIZE_BYTES -gt 262144000 ]]; then  # 250MB (Lambda limit)
    echo "❌ Error: Package size ($PACKAGE_SIZE) exceeds Lambda limit of 250MB"
    cleanup error
  fi
}

# Main package preparation logic
echo "🚀 Starting Lambda package preparation..."

if [[ -n "$ZIP_FILE" ]]; then
  echo "✅ Using provided zip file: $ZIP_FILE"
  if [[ ! -f "$ZIP_FILE" ]]; then
    echo "❌ Zip file not found: $ZIP_FILE"
    exit 1
  fi
  DEPLOYMENT_PACKAGE="$ZIP_FILE"
  
elif [[ -n "$SOURCE_DIRECTORY" ]]; then
  echo "📦 Creating zip from source directory: $SOURCE_DIRECTORY"
  
  if [[ ! -d "$SOURCE_DIRECTORY" ]]; then
    echo "❌ Source directory not found: $SOURCE_DIRECTORY"
    exit 1
  fi
  
  # Create temporary package directory
  echo "Creating temporary package directory..."
  mkdir -p lambda-package
  
  # Copy source code
  echo "Copying source code..."
  cp -r "$SOURCE_DIRECTORY"/* lambda-package/
  
  # Handle Python dependencies
  if [[ "$INSTALL_DEPENDENCIES" == "true" ]]; then
    REQUIREMENTS_PATH="$SOURCE_DIRECTORY/$REQUIREMENTS_FILE"
    install_python_deps "$REQUIREMENTS_PATH" "lambda-package/"
  fi
  
  create_package "$SOURCE_DIRECTORY"
  DEPLOYMENT_PACKAGE="lambda-deployment.zip"
  
else
  echo "📦 Creating zip from current directory"
  
  # Create temporary package directory
  echo "Creating temporary package directory..."
  mkdir -p lambda-package
  
  # Copy current directory contents (excluding common unwanted files)
  echo "Copying source files..."
  rsync -av \
    --exclude='.git*' \
    --exclude='.github*' \
    --exclude='node_modules*' \
    --exclude='__pycache__*' \
    --exclude='*.pyc' \
    --exclude='lambda-package' \
    --exclude='lambda-deployment.zip' \
    --exclude='prepare-package.sh' \
    ./ lambda-package/ --quiet
  
  # Handle Python dependencies
  if [[ "$INSTALL_DEPENDENCIES" == "true" ]]; then
    REQUIREMENTS_PATH="./$REQUIREMENTS_FILE"
    install_python_deps "$REQUIREMENTS_PATH" "lambda-package/"
  fi
  
  create_package "."
  DEPLOYMENT_PACKAGE="lambda-deployment.zip"
fi

# Kill timeout process
kill $TIMEOUT_PID 2>/dev/null || true

# Output the deployment package path
echo "DEPLOYMENT_PACKAGE=$DEPLOYMENT_PACKAGE"
echo "✅ Package preparation completed successfully"
