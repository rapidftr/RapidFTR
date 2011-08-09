require 'spec/spec_helper'

Then /^I should see "([^\"]*)" in the search results$/ do |value|

  match = page.find('//a', :text => value)
  raise Spec::Expectations::ExpectationNotMetError, "Could not find the value: #{value} in the search results" unless match
end