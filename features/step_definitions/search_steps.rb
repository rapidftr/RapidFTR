When /^I search using a name of "([^\"]*)"$/ do |name|
  Given %q{I am on the child search page}
  When "I fill in \"#{name}\" for \"Name\""
  And %q{I press "Search"}
end

When /^I select search result \#(\d+)$/ do |ordinal|
  ordinal = ordinal.to_i   - 1
  results_rows = Hpricot(response.body).search("div[@class=profiles-list-item]")
  result_row_to_select = results_rows[ordinal]
  raise "results #{results_rows.size} does not have a row #{ordinal}" if result_row_to_select.nil?
  checkbox = result_row_to_select.at("p input")
  raise 'result row to select has not checkbox' if checkbox.nil?
  check(checkbox[:id])
end

Then /^I should see "([^\"]*)" in the search results$/ do |value|

  rows = Hpricot(response.body).search("h3")

  match = rows.find do |row|
    row.search("a/text()")[0].to_plain_text == value
  end

  raise Spec::Expectations::ExpectationNotMetError, "Could not find the value: #{value} in the search results" unless match
end