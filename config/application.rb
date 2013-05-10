require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
# require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "active_resource/railtie"
require "rails/test_unit/railtie"
# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

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

    LOCALES = ['en','fr','ar','zh','es','ru']
    LOCALES_WITH_DESCRIPTION = [['-', nil],['العربية','ar'],['中文','zh'],['English', 'en'],['Français', 'fr'],['Русский', 'ru'],['Español', 'es']]

    config.gem "jammit"

    def locales
      LOCALES
    end

    def locales_with_description
      LOCALES_WITH_DESCRIPTION
    end
  end
end
