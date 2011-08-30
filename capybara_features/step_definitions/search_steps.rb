require 'spec/spec_helper'

include HpricotSearch

When /^I search using a name of "([^\"]*)"$/ do |name|
  Given %q{I am on the child search page}
  When "I fill in \"#{name}\" for \"Name\""
  And %q{I press "Search"}
end

When /^I select search result \#(\d+)$/ do |ordinal|
  ordinal = ordinal.to_i - 1
  
	checkbox = page.all(:css, "p[@class=checkbox] input[@type='checkbox']")[0]
  raise 'result row to select has not checkbox' if checkbox.nil?
  check(checkbox[:id])
end

Then /^I should see "([^\"]*)" in the search results$/ do |value|
	match = page.find('//a', :text => value)
  raise Spec::Expectations::ExpectationNotMetError, "Could not find the value: #{value} in the search results" unless match
end

When /^the "([^"]*)" field should have "([^"]*)"$/ do |field, expected_value|
  value_in_textbox = page.find_field(field).value
  if value_in_textbox != expected_value
    raise Spec::Expectations::ExpectationNotMetError, "Could not find the value: #{expected_value} in the #{field} field."
  end
end
