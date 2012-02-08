require 'uri'
require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

module WithinHelpers
  def with_scope(locator)
    locator ? within(locator) { yield } : yield
  end
end
World(WithinHelpers)

When /^I click text "([^"]*)"(?: within "([^\"]*)")?$/ do |text_value, selector|
  with_scope(selector) do
    page.find('//a', :text => text_value).click

  end
end

Then /^I should find the form with following attributes:$/ do |table|
  table.raw.flatten.each do |attribute|
    page.should have_field(attribute)
  end
end

When /^I uncheck the disabled checkbox for user "([^"]*)"$/ do |username|
  page.find("//tr[@id='user-row-#{username}']/td/input[@type='checkbox']").click
  click_button("Yes")
end

Then /^I should (not )?see "([^\"]*)" with id "([^\"]*)"$/ do |do_not_want, element, id|
  puts "Warning: element argument '#{element}' is ignored."
  should = do_not_want ? :should_not : :should
  page.send(should, have_css("##{id}"))
end

