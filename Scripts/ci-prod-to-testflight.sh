export XCODE_CONFIG=Prod
export DISTRIBUTION_GROUPS='Beta Testers'

bundle install
bundle update fastlane
# bundle exec fastlane unit_tests
bundle exec fastlane build
bundle exec fastlane distribute