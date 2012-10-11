require 'spec/spec_helper'

include HpricotSearch

When /^I search using a name of "([^\"]*)"$/ do |name|
  step %q{I am on the child search page}
  step "I fill in \"#{name}\" for \"Name\""
  step %q{I press "Search"}
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
  lambda { page.find('//a', :text => value) }.should raise_error(Capybara::ElementNotFound)
end

Then /^I should see "(.*)" as reunited in the search results$/ do |child_name|
  child_link = page.find(:xpath, "//a[text()=\"#{child_name}\"]")
  link = child_link[:href]
  child_id = nil
  link.each('/') { |s| child_id=s }
  child_id = 'child_'+child_id
  Hpricot(page.body).search("#child_#{child_id}]").search(".reunited")
end

Then /^I should not see "(.*)" as reunited in the search results$/ do |child_name|
  child_link = page.find(:xpath, "//a[text()=\"#{child_name}\"]")
  link = child_link[:href]
  child_id = nil
  link.each('/') { |s| child_id=s }
  child_id = 'child_'+child_id
  lambda { page.find(:xpath, "//div[@id=\"#{child_id}\"]/div/img[@class=\"reunited\"]") }.should raise_error(Capybara::ElementNotFound)
end

Then /^I should see following visibility of children in search results:$/ do |table|
  table.hashes.each do |child_hash|
    child_name = child_hash["name"]
    child_visibility = child_hash["visibility"].eql?("Yes")? "": "not ";
    Then "I should #{child_visibility}see \"#{child_name}\" in the search results"
  end
end
