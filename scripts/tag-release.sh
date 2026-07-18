#!/usr/bin/env bash
# Creates and pushes a git tag matching the Spark version in mkdocs.yml (extra.spark.version).
set -euo pipefail

remote=origin

usage() {
  cat <<EOF
usage: $(basename "$0") [--yes] [--help]

Creates a git tag matching the Spark version in mkdocs.yml (extra.spark.version)
and pushes it to $remote.

  -y, --yes   skip the confirmation prompt
  -h, --help  show this help and exit
EOF
}

yes=false
for arg in "$@"; do
  case "$arg" in
    --yes|-y) yes=true ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      usage >&2
      exit 1
      ;;
  esac
done

cd "$(dirname "${BASH_SOURCE[0]}")/.."

if ! command -v yq &>/dev/null; then
  echo "error: yq is required (https://github.com/mikefarah/yq)" >&2
  exit 1
fi

version=$(yq '.extra.spark.version' mkdocs.yml)
tag="v${version}"

if git rev-parse "$tag" &>/dev/null; then
  echo "error: tag $tag already exists" >&2
  exit 1
fi

if [[ "$yes" != true ]]; then
  read -r -p "Create and push tag $tag at $(git rev-parse --short HEAD) to $remote? [y/N] " reply
  case "$reply" in
    [yY]|[yY][eE][sS]) ;;
    *)
      echo "aborted"
      exit 1
      ;;
  esac
fi

git tag "$tag"
echo "created tag $tag"

git push "$remote" "$tag"
echo "pushed tag $tag to $remote"
