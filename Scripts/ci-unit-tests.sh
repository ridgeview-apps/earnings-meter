export XCODE_CONFIG=Debug

cd $(dirname $0)/..

bundle install
bundle update fastlane
bundle exec fastlane unit_tests