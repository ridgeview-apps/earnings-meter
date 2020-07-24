$default_build_config = {

    team_id: "3H5L23529U", # Ridgeview Consulting Ltd
    xcode_scheme: "Earnings Meter",
    xcode_workspace: "Earnings Meter.xcworkspace",
    export_options: {},
    output_ipa_file_name: "Earnings Meter",
    
    unit_test_devices: ["iPhone X", "iPad Air"],
  
    match_type: "adhoc", # adhoc, app-store (don't need "development", use automatic provisioning for development)
    match_git_url: "git@github.com:ridgeview-apps/ridgeview-certs.git",
    match_force_for_new_devices: true,
  
    app_store_connect_user_id: "ci.ridgeview@gmail.com", # TODO: move this to ENV variable
  
    firebase_cli_token: ENV["FIREBASE_CLI_TOKEN"],
    firebase_test_groups: "QA",
    firebase_debug: false,

    parent_bundle_id: "com.ridgeviewapps.contract-meter",
    parent_bundle_name: "Contract Meter"
  }
  
  $firebase_app_ids = {
      # Whenever you add a new app to Firebase console, map the bundle ID to the Firebase app id
  
      firebase_app_id_beta: "1:993259414356:ios:eb17eaeb199e10333c1ec1",
      firebase_app_id_prod: "1:993259414356:ios:eb17eaeb199e10333c1ec1"
  }
    
  $beta_config = $default_build_config.merge({    
    match_type: "adhoc",
    firebase_app_id: $firebase_app_ids[:firebase_app_id_beta],
    xcode_configuration: "Release",
    export_method: "ad-hoc"
  })
  
  $app_store_config = $default_build_config.merge({
    match_type: "app-store",
    firebase_app_id: $firebase_app_ids[:firebase_app_id_prod],
    xcode_configuration: "Release",
    export_method: "app-store",
    export_options: {
      includeBitcode: true,
      compileBitcode: true
    },
  })
  