require 'spec/spec_helper'

include HpricotSearch

When /^I search using a name of "([^\"]*)"$/ do |name|
  Given %q{I am on the child search page}
  When "I fill in \"#{name}\" for \"Name\""
  And %q{I press "Search"}
end

When /^I select search result \#(\d+)$/ do |ordinal|
  ordinal = ordinal.to_i - 1
  checkbox = Hpricot(response.body).checkboxes[ordinal]
  raise 'result row to select has not checkbox' if checkbox.nil?
  check(checkbox[:id])
end

Then /^I should see "([^\"]*)" in the search results$/ do |value|

  rows = Hpricot(response.body).child_name

  match = rows.find do |row|
    row.search("a/text()")[0].to_plain_text == value
  end

  raise Spec::Expectations::ExpectationNotMetError, "Could not find the value: #{value} in the search results" unless match
end