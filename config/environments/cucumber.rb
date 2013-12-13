RapidFTR::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  config.cache_classes = true
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = true

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Asset pipeline
  config.serve_static_assets = true
  config.static_cache_control = "public, max-age=3600"
end
