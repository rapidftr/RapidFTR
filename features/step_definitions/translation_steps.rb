Given /^the following translations exist:$/ do |translations|
  translations.hashes.each do |translation|
    store translation
  end
end

And /^I set the system language to "(.+)"-"(.+)"$/ do |language, locale|
  click_link I18n.t('header.system_settings')
  select(language, :from => 'locale')
  click_button I18n.t('buttons.save')
  I18n.locale = I18n.default_locale = locale
end

And /^I set the user language to "(.*)"-"(.*)"$/ do |language, locale|
  click_link 'RapidFTR logo'
  select(language, :from => 'user_locale')
  click_button(I18n.t('buttons.save'))
  I18n.locale = locale
  # I18n.backend.class.send(:include, I18n::Backend::Fallbacks)
  # I18n.fallbacks.map(I18n.locale => I18n.default_locale)
end

Then /^I should see "(.*?)" translated$/ do |text|
  expect(text).to eq(I18n.t('xxxx'))
end

def store(translation)
  I18n.backend.store_translations translation['locale'], translation['key'] => translation['value']
end
Then /^I should see my system language as "([^"]*)"-"([^"]*)"$/ do |language, locale|
  assert page.has_xpath?("//div[@class='page-content']/h2")
end
