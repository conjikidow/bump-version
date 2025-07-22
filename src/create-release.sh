#!/bin/bash
set -e

# Verify if new version tag is set
if [ -z "$NEW_VERSION_TAG" ]; then
    echo "New version tag not found. Skipping."
    exit 0
fi

# Create GitHub Release
echo "Creating GitHub Release for tag: ${NEW_VERSION_TAG}"
# --generate-notes will automatically generate release notes based on git history
gh release create "$NEW_VERSION_TAG" --target "$MERGE_COMMIT_SHA" --generate-notes

echo "GitHub Release created successfully."
