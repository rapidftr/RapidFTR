Given /^I select menu "(.+)"$/ do |text_value|
  page.find('//li', :text => text_value).click
end

And /^I select dropdown option "(.+)"$/ do |option|
  page.find('//select', :text => option).click
  page.find('//option', :text => option).click
end

And /^I remove highlight "(.+)"$/ do |highlight_field|
  page.find('//td', :text => highlight_field).find('..').click_link('remove')
end

When /^I hide "([^"]*)" from "([^"]*)"$/ do |highlight_field, arg2|
  check highlight_field
end

Then /^I should not see "([^"]*)" in Child Summary$/ do |text|
  page.should have_no_content(text)
end
