require File.expand_path('../boot', __FILE__)

require 'action_controller/railtie'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RapidFTR
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    config.autoload_paths += %W(
      #{config.root}/lib
      #{config.root}/lib/addons
      #{config.root}/lib/rapid_ftr
      #{config.root}/lib/extensions
      #{config.root}/app/presenters
    )

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Delete unnecessary ETag middleware
    config.middleware.delete Rack::ETag

    # i18n-js
    config.i18n.enforce_available_locales = false
    config.i18n.fallbacks = true

    # Asset pipeline
    config.assets.enabled = true
    config.assets.version = '1.0'
    config.assets.initialize_on_precompile = true
    config.assets.js_compressor = :uglify

    LOCALES = ['en','fr','ar','zh','es','ru']
    LOCALES_WITH_DESCRIPTION = [['-', nil],['العربية','ar'],['中文','zh'],['English', 'en'],['Français', 'fr'],['Русский', 'ru'],['Español', 'es']]

    def locales
      LOCALES
    end

    def locales_with_description
      LOCALES_WITH_DESCRIPTION
    end
  end
end
