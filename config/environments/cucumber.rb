RapidFTR::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Remove unnecessary middleware
  [ Rack::Runtime, Rails::Rack::Logger, ActionDispatch::ShowExceptions, ActionDispatch::RemoteIp,
    Rack::MethodOverride, ActionDispatch::Head ].each &config.middleware.method(:delete).to_proc
end
