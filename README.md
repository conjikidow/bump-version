# Bump Version Action

This GitHub Action automatically bumps the project version based on PR labels and creates a pull request.
Once the version bump PR is merged, it automatically creates a new tag for the bumped version.

## Features

- Automatically determines the version bump type based on PR labels.
- Uses [bump-my-version](https://github.com/callowayproject/bump-my-version) to increment the version.
- Creates a new branch and a pull request (PR) for the version bump.
- Generates a corresponding Git tag once the version bump PR is merged.

## Usage

### Workflow Example

Add the following workflow to your repository to automatically bump the version when a PR is merged. Save it as `.github/workflows/bump-version.yaml`, for example.

```yaml
name: "Bump Version"

on:
  pull_request:
    types:
      - closed

jobs:
  bump-version:
    if: github.event.pull_request.merged == true
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
    steps:
      - uses: conjikidow/bump-version@v1
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
```

### Inputs

| Name                         | Description                                     | Required | Default           |
|------------------------------|-------------------------------------------------|:--------:|-------------------|
| `github-token`               | The GitHub token for authentication             | Yes      | N/A               |
| `version-of-bump-my-version` | The version of `bump-my-version` to use         | No       | `"latest"`        |
| `label-major`                | The label used to trigger a major version bump  | No       | `"update::major"` |
| `label-minor`                | The label used to trigger a minor version bump  | No       | `"update::minor"` |
| `label-patch`                | The label used to trigger a patch version bump  | No       | `"update::patch"` |

### Configuration

To use this action, make sure your project is configured to work with `bump-my-version`.
Below is an example configuration file `.bumpversion.toml`:

```toml
[tool.bumpversion]
current_version = "0.1.0"
commit = true
message = "Bump version: {current_version} -> {new_version}"

[[tool.bumpversion.files]]
filename = "pyproject.toml"
search = 'version = "{current_version}"'
replace = 'version = "{new_version}"'
```

For more details, refer to the official [documentation](https://callowayproject.github.io/bump-my-version/reference/configuration).

## How It Works

1. Checks if the PR is merged
   - If not merged, the action skips execution.

2. Determines the bump type
   - Extracts PR labels and determines whether a major, minor, or patch bump is required.
   - If no matching labels are found, the process stops.

3. Runs `bump-my-version` to bump the version
   - Uses `bump-my-version@latest` (or specified version).
   - Checks if the version was actually updated.

4. Creates a new branch and PR for the version bump
   - If the version is updated, a new branch (`workflow/bump-version-from-X.Y.W-to-X.Y.Z`) is created.
   - A PR is automatically opened to merge the version bump.

5. After merging, creates a Git tag
   - The branch name is parsed to extract the new version number.
   - A Git tag (`vX.Y.Z`) is pushed to mark the new release.
