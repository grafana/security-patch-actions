set -e

cd ../..
echo Working from `pwd`

REF=${1:-main}
echo cd grafana-ci-sandbox-security-mirror
cd grafana-ci-sandbox-security-mirror

_branch="security-patch-testing/$(date '+%Y%m%d%H%M%S')"

echo Checking out and updating ${REF}
git checkout ${REF}
git pull origin ${REF}

echo Creating branch ${_branch} and adding commit
git checkout -b ${_branch}

echo "This is a security commit $(date)" >> newFile-security-patches
git add . && git status
git commit -m "CVE-$(date '+%Y%m%d%H%M%S')"
git push origin ${_branch}

echo Creating pull request from ${_branch} into ${REF}
gh pr create --base ${REF} --head ${_branch} --title "Test PR ${_branch} -> ${REF}" --body "This is a test PR, nothing to see here"

echo Checking out ${REF}, to leave things as we found them
git checkout ${REF}
