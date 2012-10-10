Given /^I select menu "(.+)"$/ do |text_value|
  page.find('//li', :text => text_value).click
end

And /^I remove highlight "(.+)"$/ do |highlight_field|
  page.find('//td', :text => highlight_field).find('..').click_link('remove')
end
