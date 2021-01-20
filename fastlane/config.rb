require_relative 'config_secrets'

# Base
$base_build_config = $base_config_secrets
  .merge({
    team_id: "3H5L23529U", # Ridgeview Consulting Ltd
    xcode_scheme: "EarningsMeter",
    export_options: {},
    output_name: "EarningsMeter",
    
    unit_test_devices: ["iPhone X", "iPad Air"],

    match_type: "adhoc", # adhoc, app-store (don't need "development", use automatic provisioning for development)
    match_git_url: "git@github.com:ridgeview-apps/ridgeview-certs.git",
    match_force_for_new_devices: true,

    app_center_owner_name: "RidgeviewApps",
    app_center_owner_type: "organization",
    app_center_app_name: "EarningsMeter",
    app_center_notify_testers: true, 
    app_center_destinations: "Beta Testers",
})
    
# Beta
$beta_config = $base_build_config
  .merge($beta_config_secrets)
  .merge({
    main_target_bundle_id: "com.ridgeviewapps.earnings-meter.beta",
    match_type: "adhoc",
    provisioning_profile_specifier: "match AdHoc $(PRODUCT_BUNDLE_IDENTIFIER)",
    xcode_configuration: "Release",
    export_method: "ad-hoc",
    shield_prefix: "Beta",
    shield_colour: "blue",    
  })
  
# Prod
$prod_config = $base_build_config
  .merge($prod_config_secrets)
  .merge({
    main_target_bundle_id: "com.ridgeviewapps.earnings-meter",
    match_type: "appstore",
    provisioning_profile_specifier: "match AppStore $(PRODUCT_BUNDLE_IDENTIFIER)",
    xcode_configuration: "Release",
    export_method: "app-store",
    export_options: {
      includeBitcode: true,
      compileBitcode: true
    },
  })
  