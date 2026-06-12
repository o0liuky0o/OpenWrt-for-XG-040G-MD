#!/usr/bin/env bash

set -euo pipefail

: "${GH_TOKEN:?GH_TOKEN is required}"
: "${GITHUB_REPOSITORY:?GITHUB_REPOSITORY is required}"

keep_releases="${KEEP_RELEASES:-20}"
keep_marker="${KEEP_RELEASE_MARKER:-[keep-release]}"
release_prefix="${RELEASE_PREFIX:-}"

if ! [[ "$keep_releases" =~ ^[0-9]+$ ]] || (( keep_releases < 1 )); then
  echo "KEEP_RELEASES must be a positive integer, got: ${keep_releases}"
  exit 1
fi

echo "Cleanup config: prefix=${release_prefix} keep=${keep_releases} marker=${keep_marker}"

release_json="$(
  gh release list \
    --repo "$GITHUB_REPOSITORY" \
    --exclude-drafts \
    --exclude-pre-releases \
    --limit 1000 \
    --json tagName,name,isLatest,publishedAt
)"

# 过滤出匹配前缀的 Release
if [ -n "$release_prefix" ]; then
  filtered_json=$(printf '%s\n' "$release_json" | jq -r --arg prefix "$release_prefix" '
    [.[] | select(.tagName | startswith($prefix))]
  ')
  echo "Filtering releases with prefix: ${release_prefix}"
else
  filtered_json="$release_json"
  echo "No prefix filter, processing all releases"
fi

release_count=$(printf '%s\n' "$filtered_json" | jq 'length')
echo "Found ${release_count} releases matching prefix."

if (( release_count == 0 )); then
  echo "No releases to clean up."
  exit 0
fi

mapfile -t release_tags < <(
  printf '%s\n' "$filtered_json" | jq -r 'sort_by(.publishedAt) | reverse | .[] | .tagName'
)

mapfile -t preserved_tags < <(
  printf '%s\n' "$filtered_json" | jq -r \
    --argjson keep "$keep_releases" \
    --arg marker "$keep_marker" \
    '
    sort_by(.publishedAt) | reverse as $releases |
    (
      ($releases[:$keep] | map(.tagName)) +
      ($releases | map(select(.isLatest) | .tagName)) +
      ($releases | map(select(((.name // "") | contains($marker)) or (.tagName | contains($marker))) | .tagName))
    ) | unique[]'
)

declare -A preserved_map=()
for tag in "${preserved_tags[@]}"; do
  preserved_map["$tag"]=1
done

echo "Keeping the newest ${keep_releases} releases for prefix \"${release_prefix}\", plus latest and marked."

if (( release_count <= keep_releases )); then
  echo "No cleanup needed. Keeping all ${release_count} releases."
  exit 0
fi

for tag in "${release_tags[@]}"; do
  if [[ -n "${preserved_map[$tag]:-}" ]]; then
    echo "Preserving release: ${tag}"
    continue
  fi

  echo "Deleting old release: ${tag}"
  gh release delete "$tag" --repo "$GITHUB_REPOSITORY" --cleanup-tag -y
done