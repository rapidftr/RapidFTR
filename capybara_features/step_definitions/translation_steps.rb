require 'spec/spec_helper'

Given /^the following translations exist:$/ do |translations|
  translations.hashes.each do |translation|
    I18n.backend.store_translations translation["locale"], { translation["key"] => translation["value"] }
  end
end

And /^I set the default language to (.+)$/ do |locale|
  I18n.locale = I18n.default_locale = locale.to_sym
end
