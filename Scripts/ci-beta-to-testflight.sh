export XCODE_CONFIG=Beta

cd $(dirname $0)/..

bundle install
bundle update fastlane
bundle exec fastlane unit_tests
bundle exec fastlane add_badge_overlay
bundle exec fastlane build
bundle exec fastlane distribute