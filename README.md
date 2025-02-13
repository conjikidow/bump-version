# Bump Version by Labels

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
      - uses: conjikidow/bump-version@v1.0.0
        with:
          github-token: ${{ secrets.GITHUB_TOKEN }}
          labels-to-add: "automated,version-bump"
```

### Inputs

| Name                         | Description                                     | Required | Default           |
|------------------------------|-------------------------------------------------|:--------:|-------------------|
| `github-token`               | The GitHub token for authentication             | Yes      | N/A               |
| `version-of-bump-my-version` | The version of `bump-my-version` to use         | No       | `"latest"`        |
| `label-major`                | The label used to trigger a major version bump  | No       | `"update::major"` |
| `label-minor`                | The label used to trigger a minor version bump  | No       | `"update::minor"` |
| `label-patch`                | The label used to trigger a patch version bump  | No       | `"update::patch"` |
| `labels-to-add`              | The labels to add to the PR for version bumping | No       | None              |

### Configuration

To use this action, ensure that your project is configured to work with `bump-my-version`.
Below is an example `.bumpversion.toml` configuration file:

```toml
[tool.bumpversion]
current_version = "0.1.0"
commit = false
tag = false

[[tool.bumpversion.files]]
filename = "pyproject.toml"
search = 'version = "{current_version}"'
replace = 'version = "{new_version}"'
```

Note: `commit` and `tag` should be set to `false` because this action handles these tasks automatically.

To generate a default configuration file, run the following command:

```console
uvx bump-my-version sample-config --no-prompt --destination .bumpversion.toml
```

For more details, refer to the official [bump-my-version documentation](https://callowayproject.github.io/bump-my-version/reference/configuration).

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
