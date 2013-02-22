require 'spec/spec_helper'

Given /^the following translations exist:$/ do |translations|
  translations.hashes.each do |translation|
    I18n.backend.store_translations translation["locale"], { translation["key"] => translation["value"] }
  end
end

Then /^I should see "(.*?)" translated$/ do |text|
  text.should == I18n.t("name")
end

Then /^I should not see "(.*?)" translated$/ do |arg1|
  text.should_not == I18n.t("name")
end

And /^I set the default language to "(.+)"$/ do |locale|
  set_default_language_to locale
end

def set_default_language_to(locale)
  I18n.locale = I18n.default_locale = locale.to_sym
end
