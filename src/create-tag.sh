#!/bin/bash
set -euo pipefail

branch_name="$HEAD_REF"

# Ensure branch_name is not empty
if [ -z "$branch_name" ]; then
    echo "branch_name is not set. Exiting."
    exit 1
fi

# Verify if branch_name matches the expected pattern
if ! [[ "$branch_name" =~ ^${BRANCH_PREFIX}/bump-version-from-[0-9]+\.[0-9]+\.[0-9]+-to-[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "This branch does not match the expected pattern. Skipping."
    echo "version-bumped=false" >> "$GITHUB_OUTPUT"
    echo "new-version=" >> "$GITHUB_OUTPUT"
    exit 0
fi

# Extract versions from the branch name
previous_version=$(echo "$branch_name" | sed -E "s/^${BRANCH_PREFIX}\/bump-version-from-([0-9]+\.[0-9]+\.[0-9]+)-to-[0-9]+\.[0-9]+\.[0-9]+$/\1/")
new_version=$(echo "$branch_name" | sed -E "s/^${BRANCH_PREFIX}\/bump-version-from-[0-9]+\.[0-9]+\.[0-9]+-to-([0-9]+\.[0-9]+\.[0-9]+)$/\1/")
echo "Extracted versions: previous=${previous_version}, new=${new_version}"

# Extract major and minor versions
previous_major_version=$(cut -d. -f1 <<< "$previous_version")
previous_minor_version=$(cut -d. -f1,2 <<< "$previous_version")
new_major_version=$(cut -d. -f1 <<< "$new_version")
new_minor_version=$(cut -d. -f1,2 <<< "$new_version")

# Create full version tag (e.g., v1.2.3)
echo "Creating new tag: v${new_version}"
git tag "v${new_version}" "$MERGE_COMMIT_SHA"
git push origin "v${new_version}"

# Fetch all tags from the remote
all_tags=$(git ls-remote --tags origin)

# Check for existing tags in the fetched list
existing_previous_major_tag=$(echo "$all_tags" | awk '{print $2}' | grep -E "^refs/tags/v${previous_major_version}$" || true)
existing_previous_minor_tag=$(echo "$all_tags" | awk '{print $2}' | grep -E "^refs/tags/v${previous_minor_version}$" || true)
existing_major_tag=$(echo "$all_tags" | awk '{print $2}' | grep -E "^refs/tags/v${new_major_version}$" || true)
existing_minor_tag=$(echo "$all_tags" | awk '{print $2}' | grep -E "^refs/tags/v${new_minor_version}$" || true)

if [[ -n "$existing_major_tag" ]]; then
    echo "Updating major tag: v${new_major_version}"
    git tag -f "v${new_major_version}" "$MERGE_COMMIT_SHA"
    git push -f origin "v${new_major_version}"
elif [[ -n "$existing_previous_major_tag" ]]; then
    echo "Creating new major tag: v${new_major_version} (previous major v${previous_major_version} exists)"
    git tag "v${new_major_version}" "$MERGE_COMMIT_SHA"
    git push origin "v${new_major_version}"
fi

if [[ -n "$existing_minor_tag" ]]; then
    echo "Updating minor tag: v${new_minor_version}"
    git tag -f "v${new_minor_version}" "$MERGE_COMMIT_SHA"
    git push -f origin "v${new_minor_version}"
elif [[ -n "$existing_previous_minor_tag" ]]; then
    echo "Creating new minor tag: v${new_minor_version} (previous minor v${previous_minor_version} exists)"
    git tag "v${new_minor_version}" "$MERGE_COMMIT_SHA"
    git push origin "v${new_minor_version}"
fi

echo "version-bumped=true" >> "$GITHUB_OUTPUT"
echo "new-version=${new_version}" >> "$GITHUB_OUTPUT"
