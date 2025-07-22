#!/bin/bash
set -euo pipefail

if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed. Please install it to continue." >&2
    exit 1
fi

export BUMP_MY_VERSION="uvx bump-my-version@${VERSION_OF_BUMP_MY_VERSION}"

# Get the current version before bumping
previous_version=$($BUMP_MY_VERSION show-bump | head -1 | awk '{print $1}')
echo "Current version: ${previous_version}"

# Perform the version bump
$BUMP_MY_VERSION bump "$BUMP_TYPE"

# Get the new version after bumping
current_version=$($BUMP_MY_VERSION show-bump | head -1 | awk '{print $1}')
if [[ "$previous_version" == "$current_version" ]]; then
  echo "No version bump required."
  exit 0
fi

echo "Version bumped from ${previous_version} to ${current_version}."

# Get the current branch name
base_branch=$(git branch --show-current)

# Create a new branch for the version bump
new_branch="${BRANCH_PREFIX}/bump-version-from-${previous_version}-to-${current_version}"
echo "Creating new branch: ${new_branch}"
git checkout -b "$new_branch"

# Commit the version bump changes
git add .
git commit -m "Bump version: ${previous_version} -> ${current_version}"

# Push the new branch to the repository
echo "Pushing new branch to remote..."
git push -f origin "$new_branch"

# Create a pull request for the version bump
echo "Creating pull request..."
gh pr create --title "Bump version from ${previous_version} to ${current_version}" \
             --body "This PR updates the version from ${previous_version} to ${current_version}." \
             --base "$base_branch" \
             --head "$new_branch" \
             --label "$LABELS_TO_ADD"

echo "Pull request created successfully."
