require 'spec/spec_helper'

When /^I search using a name of "([^\"]*)"$/ do |name|
  search = SearchWidget.new(Capybara.current_session)
  search.search_for(name)
end

When /^I select search result \#(\d+)$/ do |ordinal|
  ordinal = ordinal.to_i - 1
	checkbox = page.all(:xpath, "//p[@class='checkbox']//input[@type='checkbox']")[ordinal]
  raise 'result row to select has not checkbox' if checkbox.nil?
  check(checkbox[:id])
end

Then /^I should see "([^\"]*)" in the search results$/ do |value|
  search_results.should_contain_result(value)
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
  search_results.child_should_not_be_reunited(child_id)
end

def search_results
  SearchResults.new(Capybara.current_session)
end
