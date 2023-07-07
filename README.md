# Security Patch Actions

Here live the Github Actions that handle the automation for Grafana's security patching.

There are 2 sets of Action files:
- .github/workflows contains Actions that perform the mirroring, patching, and patch verifications.
- external-workflows contains Actions meant to be dropped into the upstream repo's .github/workflows folder, meant only to trigger the downstream pipelines in this repo.
- test-scripts includes bash scripts that automate some of the headache away of testing this. All scripts are hard-coded to run against grafana-ci-sandbox.

## Testing

There are a set of scripts in test-scripts that can help to test against grafana-ci-sandbox. They assume that you have the following 3 repos cloned:
- grafana/grafana-ci-sandbox
- grafana/grafana-ci-sandbox-security-mirror
- grafana/grafana-ci-sandbox-security-patches

All bash scripts are hard coded to run against grafana-ci-sandbox.


