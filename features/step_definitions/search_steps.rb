When /^I search using a name of "([^\"]*)"$/ do |name|
  search.search_for(name)
end

When /^I select search result \#(\d+)$/ do |ordinal|
  search_results.select_result(ordinal.to_i - 1)
end

Then /^I should see "([^\"]*)" in the search results$/ do |value|
  search_results.should_contain_result(value)
end

Then /^I should not see "([^\"]*)" in the search results$/ do |value|
  search_results.should_not_contain_result(value)
end

Then /^I should see "(.*)" as reunited in the search results$/ do |child_id|
  search_results.child_should_be_reunited(child_id)
end

Then /^I should not see "(.*)" as reunited in the search results$/ do |child_id|
  search_results.child_should_not_be_reunited(child_id)
end

def search
  SearchWidget.new(Capybara.current_session)
end

def search_results
  @_search_results ||= SearchResults.new(Capybara.current_session)
end
