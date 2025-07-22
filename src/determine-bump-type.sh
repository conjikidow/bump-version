#!/bin/bash
set -e

# Fetch PR labels
echo "Fetching PR labels..."
labels=$(gh api --jq '.labels.[].name' "/repos/${REPO}/pulls/${PR_NUMBER}" | tr '\n' ',' | sed 's/,$//')
echo "Found labels: ${labels}"

# Return success if a non-empty label name is found inside $labels
has_label() {
  local needle=$1
  [[ -n "$needle" && "$labels" == *"$needle"* ]]
}

# Determine bump type
bump_type="none"
if has_label "$LABEL_MAJOR"; then
  bump_type="major"
elif has_label "$LABEL_MINOR"; then
  bump_type="minor"
elif has_label "$LABEL_PATCH"; then
  bump_type="patch"
fi

echo "Bump type determined: ${bump_type}"

# Output results for GitHub Actions
echo "type=${bump_type}" >> "$GITHUB_OUTPUT"
