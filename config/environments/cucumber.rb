RapidFTR::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

    # The production environment is meant for finished, "live" apps.
    # Code is not reloaded between requests
    config.cache_classes = true
    config.eager_load = true
    config.cache_store = :null_store

    # Asset pipeline
    config.serve_static_assets = true
    config.static_cache_control = "public, max-age=#{1.year.to_i}"
    config.assets.compile = false
    config.assets.digest = true
    config.assets.compress = true

    # Force single threaded mode
    config.middleware.insert_after ActionDispatch::Static, Rack::Lock
end
