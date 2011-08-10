require 'spec/spec_helper'

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
