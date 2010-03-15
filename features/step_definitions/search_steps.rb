When /^I search using a name of "([^\"]*)"$/ do |name|
  Given %q{I am on the child search page}
  When "I fill in \"#{name}\" for \"Name\""
  And %q{I press "Search"}
end

When /^I select the first search result$/ do
  first_result_row = Hpricot(response.body).search("table tr")[1]
  raise 'table only has one row' if first_result_row.nil?
  checkbox = first_result_row.at("td input")
  raise 'first row has not checkbox' if checkbox.nil?
  check(checkbox[:id])
end

