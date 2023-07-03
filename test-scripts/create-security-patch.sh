set -e

cd ../..
echo Working from `pwd`

REF=${1:-main}
echo cd grafana-ci-sandbox-security-mirror
cd grafana-ci-sandbox-security-mirror

echo Creating commit in grafana-ci-sandbox-security-mirror/${REF}
git checkout ${REF} || git checkout -b ${REF}
git pull origin ${REF}

echo "This is a security commit $(date)" >> newFile-security-patches
git add .
git commit -m "CVE-$(date '+%Y%m%d%H%M%S')"

git format-patch -1
mkdir ../grafana-ci-sandbox-security-patches/${REF} || echo ../grafana-ci-sandbox-security-patches/${REF} exists
mv *.patch ../grafana-ci-sandbox-security-patches/${REF} 
git reset --hard origin/${REF}

echo cd ../grafana-ci-sandbox-security-patches/${REF} 
cd ../grafana-ci-sandbox-security-patches/${REF} 
git add .
git status
git commit -m "adding security patch"
git push
