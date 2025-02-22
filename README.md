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
      - uses: conjikidow/bump-version@v1.0.2
        with:
          labels-to-add: "automated,version-bump"
```

### Inputs

| Name                         | Description                                     | Required | Default               |
|------------------------------|-------------------------------------------------|:--------:|-----------------------|
| `github-token`               | The GitHub token for authentication             | No       | `${{ github.token }}` |
| `version-of-bump-my-version` | The version of `bump-my-version` to use         | No       | `"latest"`            |
| `label-major`                | The label used to trigger a major version bump  | No       | `"update::major"`     |
| `label-minor`                | The label used to trigger a minor version bump  | No       | `"update::minor"`     |
| `label-patch`                | The label used to trigger a patch version bump  | No       | `"update::patch"`     |
| `labels-to-add`              | The labels to add to the PR for version bumping | No       | None                  |

### bump-my-version Configuration

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

### GitHub Actions Permissions Setup

To enable GitHub Actions to run properly in your repository, you need to adjust the default permissions granted to the `GITHUB_TOKEN`.

Follow these steps to configure the permissions:

1. Go to the **Settings** tab of your repository.
2. On the left-hand menu, select **Actions/General**.
3. Under the **Workflow permissions** section, ensure the following options are selected:
   - **`Read and write permissions`**: This grants read and write access to the repository for all scopes.
   - **`Allow GitHub Actions to create and approve pull requests`**: This allows GitHub Actions to create pull requests.
4. Save the changes.

![image](https://github.com/user-attachments/assets/da55e896-e087-486e-aadc-7fc1283dc652)

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

### Tag Management

In addition to the full version tag (`vX.Y.Z`), this action updates existing major (`vX`) and minor (`vX.Y`) tags based on the following rules:

- If `vX.Y` exists → update to `vX.Y.Z`.
- If `vX.Y` does not exist but a previous minor tag (`vX.Y` before the update) exists → create `vX.Y` and set it to `vX.Y.Z`.
- If `vX` exists → update to `vX.Y.Z`.
- If `vX` does not exist but a previous major tag (`vX` before the update) exists → create `vX` and set it to `vX.Y.Z`.
- If neither `vX` nor `vX.Y` exist, they are not created.

#### Examples

- `v1.2.3 → v1.2.4`: Update `v1.2` and `v1` if they exist.
- `v1.2.3 → v1.3.0`: Create `v1.3` if `v1.2` exists, update `v1` if it exists.
- `v1.2.3 → v2.0.0`: Create `v2.0` if `v1.2` exists, create `v2` if `v1` exists.
