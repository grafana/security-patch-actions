set -e

cd ../..
echo Working from `pwd`

REF=${1:-main}
echo cd grafana-ci-sandbox
cd grafana-ci-sandbox

echo Checking out and updating ${REF}
git checkout ${REF}
git pull origin ${REF}

echo Copying github actions to grafana-ci-sandbox
echo cp ../security-patch-actions/external-workflows/grafana-ci-sandbox/* .github/workflows/
cp ../security-patch-actions/external-workflows/grafana-ci-sandbox/* .github/workflows/

git add . && git status
git commit -m "Updating security-patch-actions to use develop"
git push origin ${REF}
