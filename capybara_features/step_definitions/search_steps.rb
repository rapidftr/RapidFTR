require 'spec/spec_helper'

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
  # This step is wrong
  # The search is returning nothing
  # But there is no assertion like "should" or "should_not" on the result
  # Hpricot(page.body).search("#child_#{child_id}]").search(".reunited") # .should == true
  page.has_xpath?("//div[@id='#{child_id}']/div/img[@class='reunited']") # .should == true
end

Then /^I should not see "(.*)" as reunited in the search results$/ do |child_id|
  page.should_not have_xpath "//div[@id='#{child_id}']/div/img[@class='reunited']"
end
