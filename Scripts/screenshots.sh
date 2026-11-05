#!/bin/zsh
# Generates the App Store screenshots locally, for checking before an upload.
# Uploading runs on CI, so this needs no App Store Connect key.
#
#   Scripts/screenshots.sh                       # into /tmp/earnings-meter-screenshots
#   Scripts/screenshots.sh --output-dir ~/Desktop/shots
#   Scripts/screenshots.sh --device "iPhone 18 Pro Max" --languages es-ES,es-MX

set -e

output_dir=/tmp/earnings-meter-screenshots
lane_options=()

while [[ $# -gt 0 ]]; do
  case $1 in
    --output-dir) output_dir=$2; shift 2 ;;
    --device) lane_options+=("device:$2"); shift 2 ;;
    --languages) lane_options+=("languages:$2"); shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

mkdir -p "$output_dir"
output_dir=$(cd "$output_dir" && pwd)

cd $(dirname $0)/..
bundle install
bundle exec fastlane screenshots output_directory:"$output_dir" "${lane_options[@]}"
echo "Screenshots: $output_dir"
