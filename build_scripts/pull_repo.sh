#!/bin/bash

# Default values
GITHUB_TOKEN=${GITHUB_TOKEN:-""}  # Use token from env if available
REPO_URL=${1:-""}
BRANCH=${2:-"main"}
DEST_DIR=${3:-"./"}

# Function to display usage
usage() {
    echo "Usage: $0 <repository_url> [branch] [destination_directory]"
    echo "Example: $0 https://github.com/user/repo main /app"
    echo "Note: GITHUB_TOKEN environment variable can be set for private repositories"
    exit 1
}

# Check if repository URL is provided
if [ -z "$REPO_URL" ]; then
    usage
fi

# Convert HTTPS URL to format that works with token
if [ -n "$GITHUB_TOKEN" ]; then
    REPO_URL=$(echo $REPO_URL | sed "s|https://|https://$GITHUB_TOKEN@|")
fi

# Create destination directory if it doesn't exist
mkdir -p "$DEST_DIR"

# Clone the repository with verbose output
echo "Attempting to clone from: $REPO_URL"
echo "Branch: $BRANCH"
echo "Destination: $DEST_DIR"

if ! git clone -v --branch "$BRANCH" "$REPO_URL" "$DEST_DIR"; then
    echo "Failed to clone repository. Please check:"
    echo "- Repository URL is correct"
    echo "- Branch name is correct"
    echo "- You have necessary permissions"
    echo "- GitHub token is valid (if required)"
    exit 1
fi

echo "Repository cloned successfully!"
