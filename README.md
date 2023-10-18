# Security Patch Actions

Here live the Github Actions that handle the automation for [Grafana's security patching][sp].

There are 2 sets of Action files:

- `.github/workflows` contains Actions that perform the mirroring, patching, and patch verifications.
- `external-workflows` contains Actions meant to be dropped into the upstream repo's `.github/workflows` folder, intended only to trigger the downstream pipelines in this repo.

Additionally, `test-scripts` includes Bash scripts that automate some of the headache away of testing this.
All scripts are hard-coded to run against `grafana/grafana-ci-sandbox`.


## Testing

There are a set of scripts in test-scripts that can help to test against grafana-ci-sandbox, using the develop branch of this project.
They assume that you have the following 3 repos cloned in the same directory that you have the `security-patch-actions` repo cloned to:

- `grafana/grafana-ci-sandbox`
- `grafana/grafana-ci-sandbox-security-mirror`
- `grafana/grafana-ci-sandbox-security-patches`

All Bash scripts are hard coded to run against `grafana/grafana-ci-sandbox`.

### Setup test env 
- `setup-branch.sh <branch>` sets up grafana-ci-sandbox to run against the develop branch of this repo.
- `create-grafana-ci-sandbox-pr.sh <branch>` creates a PR in grafana-ci-sandbox to the branch supplied (default: main)
- `create-grafana-ci-sandbox-security-mirror-pr.sh <branch>` creates a PR in grafana-ci-sandbox-security mirror to the branch supplied (default: main)
- `create-merge-conflict-pr.sh <branch>` will create a PR to grafana-ci-sandbox that will conflict with the PR created by `create-grafana-ci-sandbox-security-mirror-pr.sh`, for testing conflicts


## Provided actions

### `create-patch.yml`

Creates a git patch from the diff between one branch and another, and uploads it to a patch repository. Meant to create security patches from pull requests.

```
gh workflow run --repo grafana/security-patch-actions create-patch.yml \
    -f repo=grafana/grafana-ci-sandbox-security-mirror \
    -f patch_repo=grafana/grafana-ci-sandbox-security-patches \
    -f src_ref=<myBranchName> \
    -f patch_ref=v10.1.x \
    -f patch_prefix=<myPrefix>
```

### `publish-patch.yml`

Publishes a single patch from a patches repository onto a ref in a destination repository.
This does not push to that branch directly but creates a pull-request.

```
gh workflow run --repo grafana/security-patch-actions publish-patch.yml \
    -f dest_repo=grafana/grafana-ci-sandbox-security-mirror \
    -f patch_repo=grafana/grafana-ci-sandbox-security-patches \
    -f ref=v10.1.x \
    -f patch_name=my-patch.patch
```
### `mirror-branch.yml`

Used for mirroring a single branch from a source repository over to a specific destination repository.
There is also an optional input called `with_conficts` which will also include conflicting files in the patch commit of the destination repository.
This should allow testing of conflicting patches in a low-risk environment.
Note that this will execute a force-push and therefore overwrite existing changes in the destination repository.

```
gh workflow run --repo grafana/security-patch-actions mirror-branch.yml \
    -f src_repo=grafana/grafana-ci-sandbox \
    -f dest_repo=grafana/grafana-ci-sandbox-security-mirror \
    -f ref=v10.1.x
```
### `mirror-branch-and-apply-patches.yml`

Mirrors a specific branch from the source repository to the destination repository and applies all the patches that are relevant for that branch.

```
gh workflow run --repo grafana/security-patch-actions mirror-branch-and-apply-patches.yml \
    -f src_repo=grafana/grafana-ci-sandbox \
    -f dest_repo=grafana/grafana-ci-sandbox-security-mirror \
    -f patch_repo=grafana/grafana-ci-sandbox-security-patches \
    -f ref=v10.1.x
```

### `mirror-tag.yml`

Used for mirroring a single tag from a source repository over to a specific destination repository.

```
gh workflow run --repo grafana/security-patch-actions mirror-tag.yml \
    -f src_repo=grafana/grafana-ci-sandbox \
    -f dest_repo=grafana/grafana-ci-sandbox-security-mirror \
    -f ref=v10.0.3
```

### `test-patches.yml`

This workflow will try to apply all security patches to a specific ref in the source repository to check for conflicts.

```
gh workflow run --repo grafana/security-patch-actions test-patches.yml \
    -f src_repo=grafana/grafana-ci-sandbox \
    -f src_ref=v10.0.x \
    -f patch_repo=grafana/grafana-ci-sandbox-security-patches \
    -f patch_ref=v10.0.x 
```


## Provided workflow templates

These are templates you can drop into your project's workflows to enable mirroring to a `${REPO_OWNER}/${REPO_NAME}-security-mirror` repository.

### `create-security-patch-from-security-mirror.yml`

Runs the `create-patch.yml` action against a pull-request targeting a version branch or main in the security-mirror.

### `pr-patch-check.yml`

Runs the `test-patches.yml` action against a newly created pull-request targeting a release branch (or main).
It expects the security patches to be stored inside a `${REPO_OWNER}/${REPO_NAME}-security-patches` repository.

### `sync-mirror.yml`

Runs the `mirror-branch-and-apply-patches.yml` workflow when a pull-request is closed that targets a release branch (or main).
It expects the security patches to be stored inside a `${REPO_OWNER}/${REPO_NAME}-security-patches` repository and the mirror to be available in `${REPO_OWNER}/${REPO_NAME}-security-mirror`.

[sp]: https://github.com/grafana/grafana-delivery/tree/main/docs/topics/security-patching
