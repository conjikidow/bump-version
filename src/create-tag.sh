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

existing_previous_major_tag=$(git ls-remote --tags origin "v${previous_major_version}" | awk '{print $2}')
existing_previous_minor_tag=$(git ls-remote --tags origin "v${previous_minor_version}" | awk '{print $2}')
existing_major_tag=$(git ls-remote --tags origin "v${new_major_version}" | awk '{print $2}')
existing_minor_tag=$(git ls-remote --tags origin "v${new_minor_version}" | awk '{print $2}')

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
