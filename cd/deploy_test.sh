# Adds an Chart to a github release 
uploadChart() {
    chart=$1
    version=$2
    token=$3

    helm dependency update "kubernetes/${chart}"
    helm package "kubernetes/${chart}"
    curl -v -H "Authorization: token $token" -H "Content-Type: application/zip" --data-binary @${chart}-${version}.tgz "https://api.github.com/repos/gchq/gaffer-docker/releases/tag/v${version}/assets"
    rm ${chart}-${version}.tgz
}

APP_VERSION="0.5.1"
TAG_NAME="v${APP_VERSION}"

# Upload Charts to Github releases
uploadChart hdfs "${APP_VERSION}" "${GITHUB_TOKEN}"
uploadChart gaffer "${APP_VERSION}" "${GITHUB_TOKEN}"
uploadChart gaffer-road-traffic "${APP_VERSION}" "${GITHUB_TOKEN}"

# Build index.yaml file
git checkout gh-pages
git merge gaffer-docker/issue#32 -m "Updated docs to latest version"
# helm repo index . --url "https://github.com/gchq/gaffer-docker/releases/tag/${TAG_NAME}"
# cat index.yaml