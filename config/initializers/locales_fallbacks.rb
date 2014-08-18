module RapidFTR
  module Translations
    def self.set_fallbacks
      I18n.backend.class.send(:include, I18n::Backend::Fallbacks)
      I18n.fallbacks.clear

      new_fallbacks = {}
      RapidFTR::Application::LOCALES.each do |locale|
        new_fallbacks[locale.to_sym] = [locale.to_sym, I18n.default_locale, :en]
      end
      I18n.fallbacks = new_fallbacks
    end
  end
end

RapidFTR::Translations.set_fallbacks
