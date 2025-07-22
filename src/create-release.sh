#!/bin/bash
set -euo pipefail

if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed. Please install it to continue." >&2
    exit 1
fi

NEW_VERSION_TAG="v${NEW_VERSION}"

# Create GitHub Release
echo "Creating GitHub Release for tag: ${NEW_VERSION_TAG}"
# --generate-notes will automatically generate release notes based on git history
gh release create "$NEW_VERSION_TAG" --target "$MERGE_COMMIT_SHA" --generate-notes

echo "GitHub Release created successfully."
