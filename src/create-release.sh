#!/bin/bash
set -e

# Ensure GH_TOKEN is set
if [ -z "$GH_TOKEN" ]; then
    echo "GH_TOKEN is not set. Exiting."
    exit 1
fi

# Ensure NEW_VERSION_TAG is set
if [ -z "$NEW_VERSION_TAG" ]; then
    echo "NEW_VERSION_TAG is not set. Exiting."
    exit 1
fi

# Ensure MERGE_COMMIT_SHA is set
if [ -z "$MERGE_COMMIT_SHA" ]; then
    echo "MERGE_COMMIT_SHA is not set. Exiting."
    exit 1
fi

# Create GitHub Release
# --generate-notes will automatically generate release notes based on git history
gh release create "$NEW_VERSION_TAG" --target "$MERGE_COMMIT_SHA" --generate-notes
