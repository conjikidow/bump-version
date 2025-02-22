#!/bin/bash
set -e

branch_name="$HEAD_REF"

# Ensure branch_name is not empty
if [ -z "$branch_name" ]; then
    echo "branch_name is not set. Exiting."
    exit 1
fi

# Verify if branch_name matches the expected pattern
if ! [[ "$branch_name" =~ ^workflow/bump-version-from-[0-9]+\.[0-9]+\.[0-9]+-to-[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "This branch does not match the expected pattern. Skipping."
    exit 0
fi

# Extract versions from the branch name
previous_version=$(echo "$branch_name" | sed -E 's/^workflow\/bump-version-from-([0-9]+\.[0-9]+\.[0-9]+)-to-[0-9]+\.[0-9]+\.[0-9]+$/\1/')
new_version=$(echo "$branch_name" | sed -E 's/^workflow\/bump-version-from-[0-9]+\.[0-9]+\.[0-9]+-to-([0-9]+\.[0-9]+\.[0-9]+)$/\1/')

# Extract major and minor versions
previous_major_version=$(cut -d. -f1 <<< "$previous_version")
previous_minor_version=$(cut -d. -f1,2 <<< "$previous_version")
new_major_version=$(cut -d. -f1 <<< "$new_version")
new_minor_version=$(cut -d. -f1,2 <<< "$new_version")

# Create full version tag (e.g., v1.2.3)
git tag "v${new_version}" "$MERGE_COMMIT_SHA"
git push origin "v${new_version}"

# Update minor tag only if the minor version changed
if [[ "$previous_minor_version" != "$new_minor_version" ]]; then
    echo "Updating minor tag: v${new_minor_version}"
    git tag -f "v${new_minor_version}" "$MERGE_COMMIT_SHA"
    git push -f origin "v${new_minor_version}"
fi

# Update major tag only if the major version changed
if [[ "$previous_major_version" != "$new_major_version" ]]; then
    echo "Updating major tag: v${new_major_version}"
    git tag -f "v${new_major_version}" "$MERGE_COMMIT_SHA"
    git push -f origin "v${new_major_version}"
fi
