# Bump Version by Labels

This GitHub Action automatically bumps the project version based on pull request (PR) labels and creates a PR.
Once the version bump PR is merged, it automatically creates a new tag and a release (optional) for the bumped version.

This action follows the principles of [semantic versioning](https://semver.org), incrementing the version number based on the labels applied to the PR.

## Features

- Automatically determines the version bump type based on PR labels.
- Uses [bump-my-version](https://github.com/callowayproject/bump-my-version) to increment the version according to semantic versioning.
- Creates a new branch and a PR for the version bump.
- Generates a corresponding Git tag once the version bump PR is merged.
- Optionally creates a GitHub Release for the new tag.

## Usage

### Workflow Example

Below are example workflows you can add to your repository to automatically bump the version when a PR is merged.
You can save them in a file such as `.github/workflows/bump-version.yaml`.

Make sure your workflow includes the following:

- The `on: pull_request: types: [closed]` trigger to run the workflow whenever a PR is closed.
- The condition `if: github.event.pull_request.merged == true` to ensure the workflow only proceeds if the PR was merged.
- The `permissions:` section to allow the workflow to update repository contents and PRs.

#### Basic Example

```yaml
name: Bump Version

on:
  pull_request:
    types: [closed]

jobs:
  bump-version:
    if: github.event.pull_request.merged == true
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
    steps:
      - name: Bump Version
        uses: conjikidow/bump-version@v2.0.1
        with:
          label-major: 'major update'
          label-minor: 'minor update'
          label-patch: 'patch update'
          labels-to-add: 'automated,version-bump'
          create-release: 'true'
```

#### Example with External Release Tools

You can also integrate this action with external tools or actions by using the outputs provided.
The following example uses [`softprops/action-gh-release`](https://github.com/softprops/action-gh-release) to create a GitHub Release when the version has actually been bumped:

```yaml
name: Bump Version with External Release

on:
  pull_request:
    types: [closed]

jobs:
  bump-version:
    if: github.event.pull_request.merged == true
    runs-on: ubuntu-latest
    permissions:
      contents: write
      pull-requests: write
    steps:
      - name: Bump Version
        id: bump-version
        uses: conjikidow/bump-version@v2.0.1

      # This step is just a placeholder. You can replace it with your own script or external tools.
      - name: Create Release Notes
        if: steps.bump-version.outputs.version-bumped == 'true'
        run: |
            cat <<EOF > custom-release-notes.md
            ## What's Changed
            ...
            EOF

      - name: Create GitHub Release
        if: steps.bump-version.outputs.version-bumped == 'true'
        uses: softprops/action-gh-release@v2
        with:
          tag_name: v${{ steps.bump-version.outputs.new-version }}
          body_path: custom-release-notes.md
```

### Inputs

| Name                         | Description                                                            | Required | Default               |
|------------------------------|------------------------------------------------------------------------|----------|-----------------------|
| `github-token`               | The GitHub token for authentication.                                   | No       | `${{ github.token }}` |
| `version-of-bump-my-version` | The version of `bump-my-version` to use.                               | No       | `'latest'`            |
| `label-major`                | The label used to trigger a major version bump.                        | No       | `'major'`             |
| `label-minor`                | The label used to trigger a minor version bump.                        | No       | `'minor'`             |
| `label-patch`                | The label used to trigger a patch version bump.                        | No       | `'patch'`             |
| `branch-prefix`              | The prefix for the version bump branch name.                           | No       | `'workflow'`          |
| `labels-to-add`              | Comma-separated string of labels to add to the PR for version bumping. | No       | `''`                  |
| `create-release`             | Whether to create a GitHub Release for the new tag.                    | No       | `'false'`             |

> [!TIP]
> Set any of `label-major`, `label-minor`, or `label-patch` to an empty string (`''`) if you want to disable that bump type.

> [!WARNING]
> Any labels specified in `labels-to-add` must already exist in your repository. If they do not, create them in advance to avoid errors.

### Outputs

| Name             | Description                                                                             |
|------------------|-----------------------------------------------------------------------------------------|
| `version-bumped` | `true` if the version was bumped and a new tag was created; otherwise, `false`.         |
| `new-version`    | The new version number (e.g., `1.2.4`). This is empty when `version-bumped` is `false`. |

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

[[tool.bumpversion.files]]
filename = "CMakeLists.txt"
search = "VERSION {current_version}"
replace = "VERSION {new_version}"
```

> [!IMPORTANT]
> `commit` and `tag` should be set to `false` because this action handles these tasks automatically.

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
   - **`Allow GitHub Actions to create and approve PRs`**: This allows GitHub Actions to create PRs.
4. Save the changes.

![image](https://github.com/user-attachments/assets/da55e896-e087-486e-aadc-7fc1283dc652)

## How It Works

1. Checks if the PR is merged
   - If not merged, the action skips execution.

2. Determines the bump type
   - Extracts PR labels and determines whether a major, minor, or patch bump is required, in accordance with semantic versioning.
   - If no matching labels are found, the process stops.

3. Runs `bump-my-version` to bump the version
   - Uses `bump-my-version@latest` (or specified version).
   - Checks if the version was actually updated.

4. Creates a new branch and PR for the version bump
   - If the version is updated, a new branch (`${branch-prefix}/bump-version-from-X.Y.W-to-X.Y.Z`) is created.
   - A PR is automatically opened to merge the version bump.

5. After merging, creates a Git tag
   - The branch name is parsed to extract the new version number.
   - A Git tag (`vX.Y.Z`) is pushed to mark the new release.

6. Optionally creates a GitHub Release
   - If `create-release` is set to `true`, a GitHub Release is created for the new tag, with automatically generated release notes.

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

## Contributing & Feedback

Contributions, bug reports, and feedback are always welcome!
Thank you for helping improve this project for everyone!
