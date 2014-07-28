RapidFTR::Application.configure do

  # The production environment is meant for finished, "live" apps.
  # Code is not reloaded between requests
  config.cache_classes = true
  config.eager_load = true
  config.cache_store = :null_store

  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Asset pipeline
  config.serve_static_assets = true
  config.static_cache_control = "public, max-age=#{1.year.to_i}"
  config.assets.compile = false
  config.assets.digest = true
  config.assets.compress = true

  # Force single threaded mode
  config.middleware.insert_after ActionDispatch::Static, Rack::Lock

  # Disable all logging and remove extra middleware if running in CI
  if ENV['CI'] == 'true'
    config.log_level = :error
    config.logger = config.assets.logger = Logger.new('/dev/null')
    [ Rails::Rack::Logger, ActionDispatch::RemoteIp, ActionDispatch::RequestId, ActionDispatch::ShowExceptions, ActionDispatch::DebugExceptions ].each do |m|
      config.middleware.delete m
    end
  end

end
