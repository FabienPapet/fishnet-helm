#!/usr/bin/env bash
#
# Release the fishnet Helm chart.
#
# Reads the version from Chart.yaml and, when that version has not been
# released yet, tags the current commit "v<version>" and pushes the tag.
# Pushing the tag triggers the release workflow (.github/workflows/release.yaml),
# which packages the chart and pushes the OCI artifact to GHCR.
#
# Usage:
#   scripts/release.sh            # tag + push for the version in Chart.yaml
#   scripts/release.sh --local    # also build the package locally for inspection
#   DRY_RUN=1 scripts/release.sh  # print actions without tagging or pushing
#
set -euo pipefail

cd "$(dirname "$0")/.."

CHART_FILE="Chart.yaml"
LOCAL_PACKAGE=0
[[ "${1:-}" == "--local" ]] && LOCAL_PACKAGE=1

err() { echo "error: $*" >&2; exit 1; }
run() {
  if [[ "${DRY_RUN:-0}" == "1" ]]; then
    echo "[dry-run] $*"
  else
    "$@"
  fi
}

command -v helm >/dev/null || err "helm not found in PATH"
command -v git  >/dev/null || err "git not found in PATH"

VERSION="$(helm show chart . | awk '/^version:/ {print $2}')"
[[ -n "$VERSION" ]] || err "could not read version from $CHART_FILE"
TAG="v${VERSION}"

echo "Chart version: $VERSION  ->  tag $TAG"

# Refuse to release a dirty tree: the tag must point at committed content.
if [[ -n "$(git status --porcelain)" ]]; then
  err "working tree is dirty; commit or stash changes before releasing"
fi

# Idempotent: bail out if this version was already released.
git fetch --tags --quiet || true
if git rev-parse -q --verify "refs/tags/${TAG}" >/dev/null; then
  err "tag ${TAG} already exists; bump 'version' in ${CHART_FILE} first"
fi

# Validate before tagging.
helm lint .
if helm plugin list 2>/dev/null | grep -q unittest; then
  helm unittest .
else
  echo "warning: helm-unittest plugin not installed; skipping unit tests" >&2
fi

if [[ "$LOCAL_PACKAGE" == "1" ]]; then
  run helm package . --version "$VERSION" --app-version "$VERSION"
  echo "Built fishnet-${VERSION}.tgz locally (not pushed)."
fi

run git tag -a "$TAG" -m "Release ${TAG}"
run git push origin "$TAG"

echo
echo "Pushed ${TAG}. The release workflow will package and push the OCI chart:"
echo "  oci://ghcr.io/fabienpapet/charts/fishnet --version ${VERSION}"
