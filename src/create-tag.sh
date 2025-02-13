#!/bin/bash
set -e

branch_name="$HEAD_REF"

# Ensure branch_name is not empty
if [ -z "$branch_name" ]; then
    echo "branch_name is not set. Exiting."
    exit 1
fi

# Verify if branch_name matches the expected pattern
branch_name=$(echo "$branch_name" | grep -E '^workflow/bump-version-from-[0-9]+\.[0-9]+\.[0-9]+-to-[0-9]+\.[0-9]+\.[0-9]+$' || echo "nomatch")
if [ "$branch_name" == "nomatch" ]; then
    echo "This branch does not match the expected pattern. Skipping."
    exit 0
fi

# Extract the version from the branch name
current_version=$(echo "$branch_name" | sed -E 's/^workflow\/bump-version-from-[0-9]+\.[0-9]+\.[0-9]+-to-([0-9]+\.[0-9]+\.[0-9]+)$/\1/')


git tag "v${current_version}" "$MERGE_COMMIT_SHA"
git push origin "v${current_version}"
