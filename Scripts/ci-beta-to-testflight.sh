export XCODE_CONFIG=Beta

bundle install
bundle update fastlane
bundle exec fastlane add_badge_overlay
bundle exec fastlane build_and_upload