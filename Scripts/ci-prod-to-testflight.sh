export XCODE_CONFIG=Prod

bundle install
bundle update fastlane
bundle exec fastlane build_and_upload