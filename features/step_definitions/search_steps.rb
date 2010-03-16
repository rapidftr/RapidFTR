When /^I search using a name of "([^\"]*)"$/ do |name|
  Given %q{I am on the child search page}
  When "I fill in \"#{name}\" for \"Name\""
  And %q{I press "Search"}
end

When /^I select search result \#(\d+)$/ do |ordinal|
  ordinal = ordinal.to_i
  result_row_to_select = Hpricot(response.body).search("table tr")[ordinal]
  raise "table does not have a row #{ordinal}" if result_row_to_select.nil?
  checkbox = result_row_to_select.at("td input")
  raise 'result row to select has not checkbox' if checkbox.nil?
  check(checkbox[:id])
end

