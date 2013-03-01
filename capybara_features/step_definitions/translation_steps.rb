require 'spec/spec_helper'

Given /^the following translations exist:$/ do |translations|
  translations.hashes.each do |translation|
    store translation
  end
end

And /^I set the system language to "(.+)"$/ do |locale|
  I18n.locale = I18n.default_locale = locale
end

And /^I set the user language to "(.+)"$/ do |locale|
  I18n.locale = locale
  I18n.backend.class.send(:include, I18n::Backend::Fallbacks)
  I18n.fallbacks.map(I18n.locale => I18n.default_locale)
end

Then /^I should see "(.*?)" translated$/ do |text|
  text.should == I18n.t("xxxx")
end

def store(translation)
  I18n.backend.store_translations translation["locale"], { translation["key"] => translation["value"] }
end
