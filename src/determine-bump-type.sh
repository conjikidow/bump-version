#!/bin/bash
set -e

# Fetch PR labels
labels=$(gh api --jq '.labels.[].name' "/repos/${REPO}/pulls/${PR_NUMBER}" | tr '\n' ',' | sed 's/,$//')

# Determine bump type
bump_type="none"
if [[ "$labels" == *"$LABEL_MAJOR"* ]]; then
  bump_type="major"
elif [[ "$labels" == *"$LABEL_MINOR"* ]]; then
  bump_type="minor"
elif [[ "$labels" == *"$LABEL_PATCH"* ]]; then
  bump_type="patch"
fi

# Output results for GitHub Actions
echo "type=${bump_type}" >> "$GITHUB_OUTPUT"
