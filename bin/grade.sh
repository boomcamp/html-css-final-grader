#!/usr/bin/env bash

set -euo pipefail

errcho() {
  >&2 echo "$@";
}

while [[ $# -gt 0 ]]
  do
    key="$1"
    case $key
      in
      -o|--output)
        output_dir=$(cd "$2"; pwd -P);
        shift
        shift
        ;;
      -r|--repo)
        repo=$2;
        shift
        shift
        ;;
      -b|--branch)
        branch=$2;
        shift
        shift
        ;;
      -i|--image)
        reference_image=$(cd "$(dirname "$2")"; pwd -P)"/$(basename "$2")"
        shift
        shift
        ;;
       --)
         shift; break;;
    esac
  done

cd "${BASH_SOURCE%/*}" || exit

errcho "Repos will be output to $output_dir"

../download_pr_repos.js --output "$TMPDIR" --repo "$repo" --branch "$branch" \
  | xargs -I{} tar -xf {} -C "$output_dir"

../grade_repos.js \
  --directories "$(find "$output_dir" -type d -depth 1)" \
  --reference "$reference_image" \
