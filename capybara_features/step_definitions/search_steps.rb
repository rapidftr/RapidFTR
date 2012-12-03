require 'spec/spec_helper'

include HpricotSearch

When /^I search using a name of "([^\"]*)"$/ do |name|
  step "I fill in \"#{name}\" for \"query\""
  step %q{I press "Go"}
end

When /^I select search result \#(\d+)$/ do |ordinal|
  ordinal = ordinal.to_i - 1
	checkbox = page.all(:css, "p[@class=checkbox] input[@type='checkbox']")[ordinal]
  raise 'result row to select has not checkbox' if checkbox.nil?
  check(checkbox[:id])
end

Then /^I should see "([^\"]*)" in the search results$/ do |value|
	match = page.find('//a', :text => value)
  raise Spec::Expectations::ExpectationNotMetError, "Could not find the value: #{value} in the search results" unless match
end

Then /^I should not see "([^\"]*)" in the search results$/ do |value|
  lambda { page.find('//a', :text => value)}.should raise_error(Capybara::ElementNotFound)
end

Then /^I should see "(.*)" as reunited in the search results$/ do |child_id|
  Hpricot(page.body).search("#child_#{child_id}]").search(".reunited")
end

Then /^I should not see "(.*)" as reunited in the search results$/ do |child_id|
  lambda { page.find(:xpath, "//div[@id=\"#{child_id}\"]/div/img[@class=\"reunited\"]") }.should raise_error(Capybara::ElementNotFound)
end
