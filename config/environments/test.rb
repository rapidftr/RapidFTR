RapidFTR::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # The test environment is used exclusively to run your application's
  # test suite.  You never need to work with it otherwise.  Remember that
  # your test database is "scratch space" for the test suite and is wiped
  # and recreated between test runs.  Don't rely on the data there!
  config.cache_classes = true
  config.eager_load = false
  config.cache_store = :null_store

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Raise exceptions instead of rendering exception templates
  config.action_dispatch.show_exceptions = false

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection    = false

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr

  # Asset pipeline
  config.serve_static_assets = false
  config.static_cache_control = "public, max-age=3600"

  # Disable all logging and remove extra middleware if running in CI
  if ENV['CI'] == 'true'
    config.log_level = :error
    config.logger = config.assets.logger = Logger.new('/dev/null')
    [ Rails::Rack::Logger, ActionDispatch::RemoteIp, ActionDispatch::RequestId, ActionDispatch::ShowExceptions, ActionDispatch::DebugExceptions ].each do |m|
      config.middleware.delete m
    end
  end
end
